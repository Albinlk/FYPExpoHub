// Bulk student enrolment (backlog U3, S4).
//
// Called by the coordinator's Enrol Students screen with their own session.
// For each row it finds the student's login by email or creates it
// (confirmed, no password: the student sets one with "Forgot password?"
// on first sign-in, which avoids the built-in mailer's hourly cap), then
// calls the audited enroll_student RPC *as the caller*, so all permission
// checks stay in the database. The service key never leaves this function.
import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type Row = { email?: string; name?: string; matric_id?: string; programme_code?: string };
type Result = { email: string; status: "enrolled" | "already_enrolled" | "error"; account_created?: boolean; message?: string };

const MAX_ROWS = 300;
const EMAIL = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "Use POST." }, 405);

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "Sign in first." }, 401);

  const url = Deno.env.get("SUPABASE_URL")!;
  const caller = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: auth } },
    auth: { persistSession: false },
  });
  const { data: allowed, error: roleError } = await caller.rpc("is_fyp_coordinator");
  if (roleError || allowed !== true) return json({ error: "Only administrators and the FYP coordinator enrol students." }, 403);

  let body: { semester_id?: string; course_code?: string; students?: Row[] };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Send JSON." }, 400);
  }
  const students = Array.isArray(body.students) ? body.students : [];
  if (!body.semester_id || students.length === 0) return json({ error: "Choose a semester and add at least one student." }, 400);
  if (students.length > MAX_ROWS) return json({ error: `At most ${MAX_ROWS} students per upload.` }, 400);

  const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, { auth: { persistSession: false } });
  const results: Result[] = [];

  for (const s of students) {
    const email = (s.email ?? "").trim().toLowerCase();
    if (!EMAIL.test(email) || !(s.name ?? "").trim() || !(s.programme_code ?? "").trim()) {
      results.push({ email, status: "error", message: "Needs an email, a name and a programme code." });
      continue;
    }
    try {
      // Existing account?
      const { data: existing } = await admin.from("profiles").select("id").eq("email", email).maybeSingle();
      let userId = existing?.id as string | undefined;
      let created = false;
      if (!userId) {
        const { data, error } = await admin.auth.admin.createUser({
          email,
          email_confirm: true,
          user_metadata: { full_name: (s.name ?? "").trim() },
        });
        if (error || !data.user) throw new Error(error?.message ?? "Could not create the account.");
        userId = data.user.id;
        created = true;
      }
      const { data: enrolled, error } = await caller.rpc("enroll_student", {
        p_user_id: userId,
        p_email: email,
        p_display_name: (s.name ?? "").trim(),
        p_programme_code: (s.programme_code ?? "").trim(),
        p_matric_id: (s.matric_id ?? "").trim() || null,
        p_semester_id: body.semester_id,
        p_course_code: body.course_code ?? "CSP600",
      });
      if (error) throw new Error(error.message);
      results.push({
        email,
        status: enrolled?.record_created ? "enrolled" : "already_enrolled",
        account_created: created,
      });
    } catch (e) {
      results.push({ email, status: "error", message: e instanceof Error ? e.message : String(e) });
    }
  }

  return json({ results });
});
