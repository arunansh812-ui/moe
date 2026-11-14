# Modern Education School – GitHub + Supabase starter

This project is a GitHub Pages-compatible frontend with a Supabase backend integration point.

## Files
- `index.html` – responsive website frontend.
- `supabase-schema.sql` – starter database schema.

## Important platform note
GitHub Pages hosts static files only. It does not provide secure authentication, database storage, private PDF storage, or server-side authorization. This project therefore uses Supabase as the backend. Do not put a Supabase `service_role` key in `index.html`.

## Setup
1. Create a Supabase project.
2. Open **SQL Editor** and run `supabase-schema.sql`.
3. In `index.html`, replace:
   - `PASTE_YOUR_SUPABASE_PROJECT_URL`
   - `PASTE_YOUR_SUPABASE_ANON_KEY`
   with the project's URL and public anon key.
4. Create storage buckets:
   - `school-documents` – for circulars and academic question papers.
   - `admission-private` – private bucket for applicant photographs and admission exam documents.
5. Deploy `index.html` to a GitHub repository and enable **Settings → Pages**.

## Security and functionality status
The frontend includes public navigation, circular and question-paper reads, live camera capture, application submission integration, status lookup integration point, and Supabase Auth login.

The following production workflows still require trusted Supabase Edge Functions and carefully tested Row Level Security policies:
- Nodal Officer-only access to admission applications.
- Nodal Officer verification and roll-number assignment.
- Private admission photo / marks / answer-sheet uploads.
- Staff assignment and role-specific permissions.
- Attendance entry, marks entry, and result publication.
#NAME?

These are intentionally not simulated as secure features in browser code. A browser-only implementation cannot safely enforce these permissions. The SQL file marks the sensitive areas requiring server-side enforcement.

## Admission authority rule
The Administrator may assign a Nodal Officer in staff management. The Administrator has no individual admission application access or admission-processing authority. The Nodal Officer owns application review, verification, roll-number assignment, and admission document uploads.

## Before using with real student data
Have a qualified developer complete and test Edge Functions, RLS policies, storage access, audit logging, backups, and privacy/consent notices. Do not collect real student information until this security work is complete.
<img width="2341" height="1393" alt="image" src="https://github.com/user-attachments/assets/10aa1169-661d-431f-b717-14c9db8e2967" />
