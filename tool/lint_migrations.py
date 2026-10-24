"""Offline approximation of the Supabase advisors over supabase/migrations.

Use it when the live advisors (Supabase dashboard, CLI or MCP) aren't
available. It reports tables without RLS, foreign keys no index starts
with, functions without a pinned search_path, and policies that call
auth.uid()/auth.jwt()/auth.role() without wrapping them in (select ...).
It parses SQL with regular expressions, so treat hits as leads to check.

    python tool/lint_migrations.py           # report
    python tool/lint_migrations.py --check   # exit 1 on any finding (CI)
"""
import glob
import os
import re
import sys

os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
files = sorted(glob.glob('supabase/migrations/*.sql'))
sql = ''
for f in files:
    sql += '\n-- FILE ' + os.path.basename(f) + '\n' + open(f, encoding='utf-8').read()
low = sql.lower()

# --- tables and RLS
tables = set(re.findall(r'create table (?:if not exists )?(?:public\.)?"?(\w+)"?', low))
rls = set(re.findall(r'alter table (?:if exists )?(?:only )?(?:public\.)?"?(\w+)"? enable row level security', low))
print('TABLES', len(tables))
print('NO RLS:', sorted(tables - rls))

# --- foreign keys: (table, column) from inline references and alter table add constraint
fks = set()
for m in re.finditer(r'create table (?:if not exists )?(?:public\.)?"?(\w+)"?\s*\((.*?)\n\);', low, re.S):
    t, body = m.group(1), m.group(2)
    for line in body.split('\n'):
        mm = re.match(r'\s*"?(\w+)"?\s+[\w\s\[\]\(\),]*?references\s', line)
        if mm and not line.strip().startswith(('constraint', 'foreign', 'primary', 'unique', 'check')):
            fks.add((t, mm.group(1)))
        mm2 = re.search(r'foreign key\s*\(\s*"?(\w+)"?\s*\)', line)
        if mm2:
            fks.add((t, mm2.group(1)))
for m in re.finditer(r'alter table (?:if exists )?(?:only )?(?:public\.)?"?(\w+)"?\s+(add column.*?);', low, re.S):
    for clause in re.split(r',\s*(?=add column)', m.group(2)):
        mm = re.match(r'add column (?:if not exists )?"?(\w+)"?[^,]*?references', clause, re.S)
        if mm:
            fks.add((m.group(1), mm.group(1)))
for m in re.finditer(r'alter table (?:if exists )?(?:only )?(?:public\.)?"?(\w+)"?\s+add constraint \w+ foreign key\s*\(\s*"?(\w+)"?', low):
    fks.add((m.group(1), m.group(2)))

# indexes: first column of each index, plus unique/primary constraints (first column)
indexed = set()
for m in re.finditer(r'create (?:unique )?index (?:concurrently )?(?:if not exists )?\w+\s+on (?:only )?(?:public\.)?"?(\w+)"?(?: using \w+)?\s*\(\s*"?(\w+)"?', low):
    indexed.add((m.group(1), m.group(2)))
for m in re.finditer(r'create table (?:if not exists )?(?:public\.)?"?(\w+)"?\s*\((.*?)\n\);', low, re.S):
    t, body = m.group(1), m.group(2)
    for line in body.split('\n'):
        mm = re.match(r'\s*"?(\w+)"?\s+.*\bprimary key\b', line)
        if mm:
            indexed.add((t, mm.group(1)))
        mm = re.match(r'\s*"?(\w+)"?\s+.*\bunique\b', line)
        if mm and not line.strip().startswith(('constraint', 'unique')):
            indexed.add((t, mm.group(1)))
        mm = re.search(r'(?:unique|primary key)\s*\(\s*"?(\w+)"?', line)
        if mm:
            indexed.add((t, mm.group(1)))
for m in re.finditer(r'alter table (?:if exists )?(?:only )?(?:public\.)?"?(\w+)"?\s+add constraint \w+ (?:unique|primary key)\s*\(\s*"?(\w+)"?', low):
    indexed.add((m.group(1), m.group(2)))
# Indexes created from a (table, column) list at apply time (see
# 20261024000001_advisor_fixes.sql), which the patterns above can't see.
for block in re.findall(r'select \* from \(values(.*?)\) as v\(tbl, col\)', low, re.S):
    indexed.update(re.findall(r"\('(\w+)', '(\w+)'\)", block))
dropped_tables = set(re.findall(r'drop table (?:if exists )?(?:public\.)?"?(\w+)"?', low))
unidx = sorted(fk for fk in fks if fk not in indexed and fk[0] in tables and fk[0] not in dropped_tables)
print('FKS', len(fks), 'UNINDEXED', len(unidx))
for t, c in unidx:
    print('  ', t, c)

# --- functions: last definition wins
funcs = {}
for m in re.finditer(r'create (?:or replace )?function\s+(?:public\.)?(\w+)\s*\((.*?)\)\s*returns(.*?)(?:\$\$|\$function\$|\$fn\$)', low, re.S):
    funcs[m.group(1)] = m.group(3)
nopath = sorted(n for n, head in funcs.items() if 'search_path' not in head)
secdef_nopath = sorted(n for n, head in funcs.items() if 'security definer' in head and 'search_path' not in head)
# later "alter function ... set search_path" fixes
fixed = set(re.findall(r'alter function (?:public\.)?(\w+)\s*\([^)]*\)\s*set search_path', low))
print('FUNCTIONS', len(funcs))
print('NO search_path (not fixed by alter):', [n for n in nopath if n not in fixed])
print('SECURITY DEFINER without search_path:', [n for n in secdef_nopath if n not in fixed])

# --- policies: auth.uid() not wrapped in a select (re-evaluated per row)
pols = {}
for m in re.finditer(r'create policy\s+"?([^"\n]+?)"?\s+on\s+(?:public\.)?"?(\w+)"?(.*?);', low, re.S):
    pols[(m.group(2), m.group(1).strip())] = m.group(3)
# Later "alter policy ... using (...)" (also inside execute $p$...$p$).
for m in re.finditer(r'alter policy\s+"([^"]+)"\s+on\s+(?:public\.)?"?(\w+)"?(.*?)(?:;|\$p\$)', low, re.S):
    if (m.group(2), m.group(1).strip()) in pols:
        pols[(m.group(2), m.group(1).strip())] = m.group(3)
for m in re.finditer(r'drop policy (?:if exists )?"?([^"\n]+?)"? on (?:public\.)?"?(\w+)"?', low):
    pols.pop((m.group(2), m.group(1).strip()), None)
initplan = sorted(k for k, body in pols.items() if re.search(r'(?<!select )auth\.(uid|jwt|role)\(\)', body))
print('POLICIES', len(pols), 'auth.*() not wrapped in select:', len(initplan))
for k in initplan[:40]:
    print('  ', k)

if '--check' in sys.argv:
    problems = (sorted(tables - rls) or unidx
                or [n for n in secdef_nopath if n not in fixed] or initplan)
    sys.exit(1 if problems else 0)
