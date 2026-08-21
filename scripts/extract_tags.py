import csv, re

# Technology keyword mapping: keyword pattern -> normalized tag
TAG_RULES = [
    # Networking protocols & infrastructure
    (r'\bMQTT\b', 'MQTT'),
    (r'\bSDN\b', 'SDN'),
    (r'\bVLAN\b', 'VLAN'),
    (r'\bDNS\b', 'DNS'),
    (r'\bOSPF\b', 'OSPF'),
    (r'\bVPN\b', 'VPN'),
    (r'\bTCP\b', 'TCP'),
    (r'\bUDP\b', 'UDP'),
    (r'\bHTTP/?3\b', 'HTTP/3'),
    (r'\b5G\b', '5G'),
    (r'\bLoRa\b', 'LoRa'),
    (r'\bWI-?FI\b', 'Wi-Fi'),
    (r'\bROIP\b', 'Radio-over-IP'),
    (r'\bLOAD BALANC', 'Load Balancing'),

    # Security & cybersecurity
    (r'\bINTRUSION DETECTION\b', 'Intrusion Detection'),
    (r'\bNIDS\b', 'NIDS'),
    (r'\bIDS\b', 'IDS'),
    (r'\bSNORT\b', 'Snort'),
    (r'\bWIRESHARK\b', 'Wireshark'),
    (r'\bPHISHING\b', 'Phishing'),
    (r'\bMALWARE\b', 'Malware'),
    (r'\bRANSOMWARE\b', 'Ransomware'),
    (r'\bDEEPFAKE\b', 'Deepfake'),
    (r'\bDDOS\b', 'DDoS'),
    (r'\bPENETRATION TEST\b', 'Penetration Testing'),
    (r'\bZERO TRUST\b', 'Zero Trust'),
    (r'\bFIREWALL\b', 'Firewall'),
    (r'\bHONEYPOT\b', 'Honeypot'),
    (r'\bVULNERABILITY\b', 'Vulnerability Scanning'),
    (r'\bANOMALY DETECTION\b', 'Anomaly Detection'),
    (r'\bNETWORK TRAFFIC\b', 'Network Traffic Analysis'),
    (r'\bFORENSIC\b', 'Digital Forensics'),
    (r'\bCYBER.?PHYSICAL\b', 'Cyber-Physical Systems'),
    (r'\bSMISHING\b', 'Smishing Detection'),
    (r'\bMALICIOUS QR\b', 'QR Code Security'),

    # AI & Machine Learning
    (r'\bMACHINE LEARNING\b', 'Machine Learning'),
    (r'\bDEEP LEARNING\b', 'Deep Learning'),
    (r'\bRANDOM FOREST\b', 'Random Forest'),
    (r'\bDECISION TREE\b', 'Decision Tree'),
    (r'\bARTIFICIAL INTELLIGENCE\b', 'Artificial Intelligence'),
    (r'\bEXPLAINABLE AI\b', 'Explainable AI'),
    (r'\bXAI\b', 'Explainable AI'),
    (r'\bLLM\b', 'LLM'),
    (r'\bDEEPSEEK\b', 'LLM'),
    (r'\bAI\b', 'AI'),

    # IoT & Embedded
    (r'\bIOT\b', 'IoT'),
    (r'\bESP32\b', 'ESP32'),
    (r'\bSENSOR\b', 'Sensor'),
    (r'\bMESH\b', 'IoT Mesh'),

    # Blockchain
    (r'\bBLOCKCHAIN\b', 'Blockchain'),

    # Cloud & DevOps
    (r'\bDOCKER\b', 'Docker'),
    (r'\bCLOUD\b', 'Cloud Computing'),
    (r'\bCONTAINER\b', 'Container'),
    (r'\bPROMETHEUS\b', 'Prometheus'),
    (r'\bNESTJS\b', 'NestJS'),
    (r'\bGNS3\b', 'GNS3'),
    (r'\bMININET\b', 'Mininet'),

    # Mobile & biometrics
    (r'\bANDROID\b', 'Android'),
    (r'\bMOBILE\b', 'Mobile App'),
    (r'\bFINGERPRINT\b', 'Fingerprint'),
    (r'\bFACE RECOGNITION\b', 'Face Recognition'),

    # Web
    (r'\bWEB\b', 'Web Application'),

    # Monitoring & dashboards
    (r'\bMONITORING DASHBOARD\b', 'Monitoring Dashboard'),
    (r'\bDASHBOARD\b', 'Dashboard'),

    # Specific domains
    (r'\bEMAIL\b', 'Email Security'),
    (r'\bVOIP\b', 'VoIP'),
    (r'\bNAS\b', 'NAS'),
    (r'\bDOCUMENT MANAGEMENT\b', 'Document Management'),
    (r'\bTRAFFIC FORENSIC\b', 'Network Forensics'),
]


def extract_tags(title: str) -> list[str]:
    tags = []
    for pattern, tag in TAG_RULES:
        if re.search(pattern, title, re.IGNORECASE):
            if tag not in tags:
                tags.append(tag)
    return tags


# Read CSV, extract tags, rewrite
csv_path = r'D:\MobileAppDev\FYPExpoHub\assets\data\csp600-proposals.csv'
rows = []
with open(csv_path, encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        tags = extract_tags(row['title'])
        row['technology_tags'] = ';'.join(tags)
        rows.append(row)

with open(csv_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=reader.fieldnames)
    writer.writeheader()
    writer.writerows(rows)

# Stats
tagged = sum(1 for r in rows if r['technology_tags'])
untagged = sum(1 for r in rows if not r['technology_tags'])
all_tags = set()
for r in rows:
    for t in r['technology_tags'].split(';'):
        if t.strip():
            all_tags.add(t.strip())

print(f'Tagged: {tagged} / {len(rows)}')
print(f'Untagged: {untagged}')
print(f'\nUnique tags ({len(all_tags)}):')
for t in sorted(all_tags):
    count = sum(1 for r in rows if t in r['technology_tags'].split(';'))
    print(f'  {t}: {count}')
