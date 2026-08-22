-- Fix malformed team_display_name values stored as '["NAME"]' instead of 'NAME'
-- Legacy seed inserted JSON-stringified array into text column
UPDATE projects
SET team_display_name = student_team->>0
WHERE team_display_name LIKE '[%'
  AND student_team IS NOT NULL
  AND jsonb_array_length(student_team) > 0;
