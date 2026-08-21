export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.15"
  }
  public: {
    Tables: {
      academic_courses: {
        Row: {
          code: string
          created_at: string
          credit_hours: number
          is_active: boolean
          name: string
          stage: string
          updated_at: string
        }
        Insert: {
          code: string
          created_at?: string
          credit_hours?: number
          is_active?: boolean
          name: string
          stage: string
          updated_at?: string
        }
        Update: {
          code?: string
          created_at?: string
          credit_hours?: number
          is_active?: boolean
          name?: string
          stage?: string
          updated_at?: string
        }
        Relationships: []
      }
      academic_semesters: {
        Row: {
          code: string
          created_at: string
          end_date: string
          id: string
          label: string
          start_date: string
          status: string
          updated_at: string
        }
        Insert: {
          code: string
          created_at?: string
          end_date: string
          id?: string
          label: string
          start_date: string
          status?: string
          updated_at?: string
        }
        Update: {
          code?: string
          created_at?: string
          end_date?: string
          id?: string
          label?: string
          start_date?: string
          status?: string
          updated_at?: string
        }
        Relationships: []
      }
      activities: {
        Row: {
          actor_id: string | null
          actor_type: string | null
          created_at: string
          event_type: string | null
          id: string
          message: string | null
          metadata: Json | null
        }
        Insert: {
          actor_id?: string | null
          actor_type?: string | null
          created_at?: string
          event_type?: string | null
          id?: string
          message?: string | null
          metadata?: Json | null
        }
        Update: {
          actor_id?: string | null
          actor_type?: string | null
          created_at?: string
          event_type?: string | null
          id?: string
          message?: string | null
          metadata?: Json | null
        }
        Relationships: []
      }
      announcements: {
        Row: {
          body: string
          category: string | null
          created_at: string
          event_id: string
          id: string
          is_pinned: boolean
          publication_status: string
          published_at: string | null
          title: string
          updated_at: string
        }
        Insert: {
          body: string
          category?: string | null
          created_at?: string
          event_id: string
          id?: string
          is_pinned?: boolean
          publication_status?: string
          published_at?: string | null
          title: string
          updated_at?: string
        }
        Update: {
          body?: string
          category?: string | null
          created_at?: string
          event_id?: string
          id?: string
          is_pinned?: boolean
          publication_status?: string
          published_at?: string | null
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "announcements_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      audit_logs: {
        Row: {
          action: string
          actor_role: string | null
          actor_uid: string | null
          created_at: string
          event_id: string | null
          id: string
          import_id: string | null
          metadata_safe: Json
          source: string
          target_id: string | null
          target_type: string
        }
        Insert: {
          action: string
          actor_role?: string | null
          actor_uid?: string | null
          created_at?: string
          event_id?: string | null
          id?: string
          import_id?: string | null
          metadata_safe?: Json
          source?: string
          target_id?: string | null
          target_type: string
        }
        Update: {
          action?: string
          actor_role?: string | null
          actor_uid?: string | null
          created_at?: string
          event_id?: string | null
          id?: string
          import_id?: string | null
          metadata_safe?: Json
          source?: string
          target_id?: string | null
          target_type?: string
        }
        Relationships: [
          {
            foreignKeyName: "audit_logs_actor_uid_fkey"
            columns: ["actor_uid"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "audit_logs_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "audit_logs_import_id_fkey"
            columns: ["import_id"]
            isOneToOne: false
            referencedRelation: "imports"
            referencedColumns: ["id"]
          },
        ]
      }
      award_categories: {
        Row: {
          created_at: string
          description: string | null
          event_id: string
          id: string
          sort_order: number
          status: string
          title: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          event_id: string
          id?: string
          sort_order?: number
          status?: string
          title: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          event_id?: string
          id?: string
          sort_order?: number
          status?: string
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "award_categories_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      award_winners: {
        Row: {
          category_id: string | null
          created_at: string
          description: string | null
          event_id: string
          id: string
          programme_code: string | null
          project_id: string | null
          publication_status: string
          sponsor: string | null
          supervisor_display_name: string | null
          team_display_name: string | null
          title: string
          updated_at: string
        }
        Insert: {
          category_id?: string | null
          created_at?: string
          description?: string | null
          event_id: string
          id?: string
          programme_code?: string | null
          project_id?: string | null
          publication_status?: string
          sponsor?: string | null
          supervisor_display_name?: string | null
          team_display_name?: string | null
          title: string
          updated_at?: string
        }
        Update: {
          category_id?: string | null
          created_at?: string
          description?: string | null
          event_id?: string
          id?: string
          programme_code?: string | null
          project_id?: string | null
          publication_status?: string
          sponsor?: string | null
          supervisor_display_name?: string | null
          team_display_name?: string | null
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "award_winners_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "award_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "award_winners_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "award_winners_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      booths: {
        Row: {
          booth_number: string
          created_at: string
          event_id: string
          floor_plan_url: string | null
          id: string
          linked_project_id: string | null
          location_note: string | null
          presentation_day: string | null
          publication_status: string
          status: string
          updated_at: string
          venue: string | null
          zone: string | null
        }
        Insert: {
          booth_number: string
          created_at?: string
          event_id: string
          floor_plan_url?: string | null
          id?: string
          linked_project_id?: string | null
          location_note?: string | null
          presentation_day?: string | null
          publication_status?: string
          status?: string
          updated_at?: string
          venue?: string | null
          zone?: string | null
        }
        Update: {
          booth_number?: string
          created_at?: string
          event_id?: string
          floor_plan_url?: string | null
          id?: string
          linked_project_id?: string | null
          location_note?: string | null
          presentation_day?: string | null
          publication_status?: string
          status?: string
          updated_at?: string
          venue?: string | null
          zone?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "booths_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "booths_linked_project_id_fkey"
            columns: ["linked_project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      channels: {
        Row: {
          account_name: string | null
          created_at: string
          granted_scopes: string[] | null
          id: string
          owner_id: string
          platform: string
          platform_account_id: string | null
          profile_url: string | null
          status: string | null
          token_expires_at: string | null
          token_secret_name: string | null
          updated_at: string
        }
        Insert: {
          account_name?: string | null
          created_at?: string
          granted_scopes?: string[] | null
          id?: string
          owner_id: string
          platform: string
          platform_account_id?: string | null
          profile_url?: string | null
          status?: string | null
          token_expires_at?: string | null
          token_secret_name?: string | null
          updated_at?: string
        }
        Update: {
          account_name?: string | null
          created_at?: string
          granted_scopes?: string[] | null
          id?: string
          owner_id?: string
          platform?: string
          platform_account_id?: string | null
          profile_url?: string | null
          status?: string | null
          token_expires_at?: string | null
          token_secret_name?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "channels_owner_id_fkey"
            columns: ["owner_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["uid"]
          },
        ]
      }
      content: {
        Row: {
          approved_at: string | null
          approved_by: string | null
          assets: Json | null
          created_at: string
          description: string | null
          destination_posts: Json | null
          duration: number | null
          id: string
          owner_id: string
          scheduled_at: string | null
          selected_destinations: string[] | null
          site_sync_status: string | null
          thumbnail_url: string | null
          timezone: string | null
          title: string
          type: string | null
          updated_at: string
          version: number | null
          video_url: string | null
          workflow_status: string
        }
        Insert: {
          approved_at?: string | null
          approved_by?: string | null
          assets?: Json | null
          created_at?: string
          description?: string | null
          destination_posts?: Json | null
          duration?: number | null
          id?: string
          owner_id: string
          scheduled_at?: string | null
          selected_destinations?: string[] | null
          site_sync_status?: string | null
          thumbnail_url?: string | null
          timezone?: string | null
          title: string
          type?: string | null
          updated_at?: string
          version?: number | null
          video_url?: string | null
          workflow_status?: string
        }
        Update: {
          approved_at?: string | null
          approved_by?: string | null
          assets?: Json | null
          created_at?: string
          description?: string | null
          destination_posts?: Json | null
          duration?: number | null
          id?: string
          owner_id?: string
          scheduled_at?: string | null
          selected_destinations?: string[] | null
          site_sync_status?: string | null
          thumbnail_url?: string | null
          timezone?: string | null
          title?: string
          type?: string | null
          updated_at?: string
          version?: number | null
          video_url?: string | null
          workflow_status?: string
        }
        Relationships: [
          {
            foreignKeyName: "content_owner_id_fkey"
            columns: ["owner_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["uid"]
          },
        ]
      }
      events: {
        Row: {
          created_at: string
          daily_hours: string | null
          description: string | null
          end_at: string
          faq_items: Json
          hero_image_url: string | null
          id: string
          location_details: string | null
          map_url: string | null
          objectives: Json
          poster_url: string | null
          public_contact_email: string | null
          publication_status: string
          session_label: string | null
          slug: string
          start_at: string
          status: string
          title: string
          updated_at: string
          updated_by: string | null
          venue: string | null
        }
        Insert: {
          created_at?: string
          daily_hours?: string | null
          description?: string | null
          end_at: string
          faq_items?: Json
          hero_image_url?: string | null
          id?: string
          location_details?: string | null
          map_url?: string | null
          objectives?: Json
          poster_url?: string | null
          public_contact_email?: string | null
          publication_status?: string
          session_label?: string | null
          slug: string
          start_at: string
          status?: string
          title: string
          updated_at?: string
          updated_by?: string | null
          venue?: string | null
        }
        Update: {
          created_at?: string
          daily_hours?: string | null
          description?: string | null
          end_at?: string
          faq_items?: Json
          hero_image_url?: string | null
          id?: string
          location_details?: string | null
          map_url?: string | null
          objectives?: Json
          poster_url?: string | null
          public_contact_email?: string | null
          publication_status?: string
          session_label?: string | null
          slug?: string
          start_at?: string
          status?: string
          title?: string
          updated_at?: string
          updated_by?: string | null
          venue?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "events_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      feedback_entries: {
        Row: {
          admin_note: string | null
          created_at: string
          event_id: string | null
          id: string
          message: string
          rating: number | null
          status: string
          subject: string
          submitted_by: string | null
          updated_at: string
          user_agent: string | null
        }
        Insert: {
          admin_note?: string | null
          created_at?: string
          event_id?: string | null
          id?: string
          message: string
          rating?: number | null
          status?: string
          subject: string
          submitted_by?: string | null
          updated_at?: string
          user_agent?: string | null
        }
        Update: {
          admin_note?: string | null
          created_at?: string
          event_id?: string | null
          id?: string
          message?: string
          rating?: number | null
          status?: string
          subject?: string
          submitted_by?: string | null
          updated_at?: string
          user_agent?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "feedback_entries_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "feedback_entries_submitted_by_fkey"
            columns: ["submitted_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_audit_logs: {
        Row: {
          action: string
          actor_role: string | null
          actor_uid: string | null
          created_at: string
          id: string
          metadata_safe: Json
          source: string
          target_id: string | null
          target_type: string
        }
        Insert: {
          action: string
          actor_role?: string | null
          actor_uid?: string | null
          created_at?: string
          id?: string
          metadata_safe?: Json
          source?: string
          target_id?: string | null
          target_type: string
        }
        Update: {
          action?: string
          actor_role?: string | null
          actor_uid?: string | null
          created_at?: string
          id?: string
          metadata_safe?: Json
          source?: string
          target_id?: string | null
          target_type?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_audit_logs_actor_uid_fkey"
            columns: ["actor_uid"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_correction_confirmations: {
        Row: {
          comment: string | null
          confirmed_at: string
          confirmed_by: string
          correction_item_id: string
          created_at: string
          id: string
          updated_at: string
        }
        Insert: {
          comment?: string | null
          confirmed_at?: string
          confirmed_by: string
          correction_item_id: string
          created_at?: string
          id?: string
          updated_at?: string
        }
        Update: {
          comment?: string | null
          confirmed_at?: string
          confirmed_by?: string
          correction_item_id?: string
          created_at?: string
          id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_correction_confirmations_confirmed_by_fkey"
            columns: ["confirmed_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_correction_confirmations_correction_item_id_fkey"
            columns: ["correction_item_id"]
            isOneToOne: false
            referencedRelation: "fyp_correction_items"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_correction_items: {
        Row: {
          created_at: string
          created_by: string | null
          description: string
          form_submission_id: string | null
          fyp_record_id: string
          id: string
          item_code: string
          severity: string
          status: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          created_by?: string | null
          description: string
          form_submission_id?: string | null
          fyp_record_id: string
          id?: string
          item_code: string
          severity: string
          status?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          created_by?: string | null
          description?: string
          form_submission_id?: string | null
          fyp_record_id?: string
          id?: string
          item_code?: string
          severity?: string
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_correction_items_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_correction_items_form_submission_id_fkey"
            columns: ["form_submission_id"]
            isOneToOne: false
            referencedRelation: "fyp_form_submissions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_correction_items_fyp_record_id_fkey"
            columns: ["fyp_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_course_offerings: {
        Row: {
          academic_semester_id: string
          course_code: string
          created_at: string
          id: string
          is_active: boolean
          lecturer_id: string | null
          max_students: number | null
          updated_at: string
        }
        Insert: {
          academic_semester_id: string
          course_code: string
          created_at?: string
          id?: string
          is_active?: boolean
          lecturer_id?: string | null
          max_students?: number | null
          updated_at?: string
        }
        Update: {
          academic_semester_id?: string
          course_code?: string
          created_at?: string
          id?: string
          is_active?: boolean
          lecturer_id?: string | null
          max_students?: number | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_course_offerings_academic_semester_id_fkey"
            columns: ["academic_semester_id"]
            isOneToOne: false
            referencedRelation: "academic_semesters"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_course_offerings_course_code_fkey"
            columns: ["course_code"]
            isOneToOne: false
            referencedRelation: "academic_courses"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "fyp_course_offerings_lecturer_id_fkey"
            columns: ["lecturer_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_deliverables: {
        Row: {
          created_at: string
          deliverable_type: string
          description: string | null
          file_url: string | null
          fyp_record_id: string
          id: string
          is_required: boolean
          submitted_at: string | null
          submitted_by: string | null
          title: string
          updated_at: string
          version: number
        }
        Insert: {
          created_at?: string
          deliverable_type: string
          description?: string | null
          file_url?: string | null
          fyp_record_id: string
          id?: string
          is_required?: boolean
          submitted_at?: string | null
          submitted_by?: string | null
          title: string
          updated_at?: string
          version?: number
        }
        Update: {
          created_at?: string
          deliverable_type?: string
          description?: string | null
          file_url?: string | null
          fyp_record_id?: string
          id?: string
          is_required?: boolean
          submitted_at?: string | null
          submitted_by?: string | null
          title?: string
          updated_at?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "fyp_deliverables_fyp_record_id_fkey"
            columns: ["fyp_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_deliverables_submitted_by_fkey"
            columns: ["submitted_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_expo_publications: {
        Row: {
          created_at: string
          event_id: string
          fyp_record_id: string
          id: string
          payload: Json
          prepared_at: string | null
          prepared_by: string | null
          published_at: string | null
          published_by: string | null
          published_project_id: string | null
          status: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          event_id: string
          fyp_record_id: string
          id?: string
          payload?: Json
          prepared_at?: string | null
          prepared_by?: string | null
          published_at?: string | null
          published_by?: string | null
          published_project_id?: string | null
          status?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          event_id?: string
          fyp_record_id?: string
          id?: string
          payload?: Json
          prepared_at?: string | null
          prepared_by?: string | null
          published_at?: string | null
          published_by?: string | null
          published_project_id?: string | null
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_expo_publications_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_expo_publications_fyp_record_id_fkey"
            columns: ["fyp_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_expo_publications_prepared_by_fkey"
            columns: ["prepared_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_expo_publications_published_by_fkey"
            columns: ["published_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_expo_publications_published_project_id_fkey"
            columns: ["published_project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_form_evaluations: {
        Row: {
          comments: string | null
          created_at: string
          evaluated_at: string | null
          evaluator_id: string
          form_submission_id: string
          id: string
          rubric_template_id: string | null
          scores: Json
          status: string
          updated_at: string
          weighted_total: number
        }
        Insert: {
          comments?: string | null
          created_at?: string
          evaluated_at?: string | null
          evaluator_id: string
          form_submission_id: string
          id?: string
          rubric_template_id?: string | null
          scores?: Json
          status?: string
          updated_at?: string
          weighted_total?: number
        }
        Update: {
          comments?: string | null
          created_at?: string
          evaluated_at?: string | null
          evaluator_id?: string
          form_submission_id?: string
          id?: string
          rubric_template_id?: string | null
          scores?: Json
          status?: string
          updated_at?: string
          weighted_total?: number
        }
        Relationships: [
          {
            foreignKeyName: "fyp_form_evaluations_evaluator_id_fkey"
            columns: ["evaluator_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_form_evaluations_form_submission_id_fkey"
            columns: ["form_submission_id"]
            isOneToOne: false
            referencedRelation: "fyp_form_submissions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_form_evaluations_rubric_template_id_fkey"
            columns: ["rubric_template_id"]
            isOneToOne: false
            referencedRelation: "fyp_rubric_templates"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_form_submissions: {
        Row: {
          created_at: string
          form_code: string
          form_version: number
          fyp_record_id: string
          id: string
          payload: Json
          status: string
          submitted_at: string | null
          submitted_by: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          form_code: string
          form_version?: number
          fyp_record_id: string
          id?: string
          payload?: Json
          status?: string
          submitted_at?: string | null
          submitted_by?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          form_code?: string
          form_version?: number
          fyp_record_id?: string
          id?: string
          payload?: Json
          status?: string
          submitted_at?: string | null
          submitted_by?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_form_submissions_fyp_record_id_fkey"
            columns: ["fyp_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_form_submissions_submitted_by_fkey"
            columns: ["submitted_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_lean_canvases: {
        Row: {
          blocks: Json
          canvas_version: number
          created_at: string
          fyp_record_id: string
          id: string
          is_latest: boolean
          updated_at: string
        }
        Insert: {
          blocks?: Json
          canvas_version?: number
          created_at?: string
          fyp_record_id: string
          id?: string
          is_latest?: boolean
          updated_at?: string
        }
        Update: {
          blocks?: Json
          canvas_version?: number
          created_at?: string
          fyp_record_id?: string
          id?: string
          is_latest?: boolean
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_lean_canvases_fyp_record_id_fkey"
            columns: ["fyp_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_marks_summaries: {
        Row: {
          academic_semester_id: string
          course_code: string
          created_at: string
          export_payload: Json | null
          finalized_at: string | null
          finalized_by: string | null
          fyp_record_id: string
          grade: string | null
          id: string
          is_finalized: boolean
          marks: Json
          updated_at: string
          weighted_total: number
        }
        Insert: {
          academic_semester_id: string
          course_code: string
          created_at?: string
          export_payload?: Json | null
          finalized_at?: string | null
          finalized_by?: string | null
          fyp_record_id: string
          grade?: string | null
          id?: string
          is_finalized?: boolean
          marks?: Json
          updated_at?: string
          weighted_total?: number
        }
        Update: {
          academic_semester_id?: string
          course_code?: string
          created_at?: string
          export_payload?: Json | null
          finalized_at?: string | null
          finalized_by?: string | null
          fyp_record_id?: string
          grade?: string | null
          id?: string
          is_finalized?: boolean
          marks?: Json
          updated_at?: string
          weighted_total?: number
        }
        Relationships: [
          {
            foreignKeyName: "fyp_marks_summaries_academic_semester_id_fkey"
            columns: ["academic_semester_id"]
            isOneToOne: false
            referencedRelation: "academic_semesters"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_marks_summaries_course_code_fkey"
            columns: ["course_code"]
            isOneToOne: false
            referencedRelation: "academic_courses"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "fyp_marks_summaries_finalized_by_fkey"
            columns: ["finalized_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_marks_summaries_fyp_record_id_fkey"
            columns: ["fyp_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_milestone_extensions: {
        Row: {
          created_at: string
          decided_at: string | null
          decided_by: string | null
          decision_comment: string | null
          id: string
          milestone_id: string
          reason: string
          requested_by: string
          requested_due_date: string
          status: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          decided_at?: string | null
          decided_by?: string | null
          decision_comment?: string | null
          id?: string
          milestone_id: string
          reason: string
          requested_by: string
          requested_due_date: string
          status?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          decided_at?: string | null
          decided_by?: string | null
          decision_comment?: string | null
          id?: string
          milestone_id?: string
          reason?: string
          requested_by?: string
          requested_due_date?: string
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_milestone_extensions_decided_by_fkey"
            columns: ["decided_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_milestone_extensions_milestone_id_fkey"
            columns: ["milestone_id"]
            isOneToOne: false
            referencedRelation: "fyp_milestones"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_milestone_extensions_requested_by_fkey"
            columns: ["requested_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_milestones: {
        Row: {
          completed_at: string | null
          created_at: string
          description: string | null
          fyp_record_id: string
          id: string
          milestone_code: string
          milestone_title: string
          status: string
          target_date: string | null
          updated_at: string
        }
        Insert: {
          completed_at?: string | null
          created_at?: string
          description?: string | null
          fyp_record_id: string
          id?: string
          milestone_code: string
          milestone_title: string
          status?: string
          target_date?: string | null
          updated_at?: string
        }
        Update: {
          completed_at?: string | null
          created_at?: string
          description?: string | null
          fyp_record_id?: string
          id?: string
          milestone_code?: string
          milestone_title?: string
          status?: string
          target_date?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_milestones_fyp_record_id_fkey"
            columns: ["fyp_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_presentation_sessions: {
        Row: {
          created_at: string
          end_at: string
          event_date: string
          id: string
          offering_id: string
          session_code: string
          session_title: string
          session_type: string
          start_at: string
          updated_at: string
          venue: string | null
        }
        Insert: {
          created_at?: string
          end_at: string
          event_date: string
          id?: string
          offering_id: string
          session_code: string
          session_title: string
          session_type?: string
          start_at: string
          updated_at?: string
          venue?: string | null
        }
        Update: {
          created_at?: string
          end_at?: string
          event_date?: string
          id?: string
          offering_id?: string
          session_code?: string
          session_title?: string
          session_type?: string
          start_at?: string
          updated_at?: string
          venue?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fyp_presentation_sessions_offering_id_fkey"
            columns: ["offering_id"]
            isOneToOne: false
            referencedRelation: "fyp_course_offerings"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_presentation_slots: {
        Row: {
          created_at: string
          end_at: string
          fyp_record_id: string
          id: string
          room: string | null
          session_id: string
          slot_number: number
          start_at: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          end_at: string
          fyp_record_id: string
          id?: string
          room?: string | null
          session_id: string
          slot_number: number
          start_at: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          end_at?: string
          fyp_record_id?: string
          id?: string
          room?: string | null
          session_id?: string
          slot_number?: number
          start_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_presentation_slots_fyp_record_id_fkey"
            columns: ["fyp_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_presentation_slots_session_id_fkey"
            columns: ["session_id"]
            isOneToOne: false
            referencedRelation: "fyp_presentation_sessions"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_progress_logs: {
        Row: {
          challenges: string | null
          created_at: string
          fyp_record_id: string
          id: string
          next_plan: string | null
          progress_date: string
          status: string
          submitted_at: string | null
          submitted_by: string | null
          summary: string
          updated_at: string
          validated_at: string | null
          validated_by: string | null
          validation_comment: string | null
          week_number: number
        }
        Insert: {
          challenges?: string | null
          created_at?: string
          fyp_record_id: string
          id?: string
          next_plan?: string | null
          progress_date: string
          status?: string
          submitted_at?: string | null
          submitted_by?: string | null
          summary: string
          updated_at?: string
          validated_at?: string | null
          validated_by?: string | null
          validation_comment?: string | null
          week_number: number
        }
        Update: {
          challenges?: string | null
          created_at?: string
          fyp_record_id?: string
          id?: string
          next_plan?: string | null
          progress_date?: string
          status?: string
          submitted_at?: string | null
          submitted_by?: string | null
          summary?: string
          updated_at?: string
          validated_at?: string | null
          validated_by?: string | null
          validation_comment?: string | null
          week_number?: number
        }
        Relationships: [
          {
            foreignKeyName: "fyp_progress_logs_fyp_record_id_fkey"
            columns: ["fyp_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_progress_logs_submitted_by_fkey"
            columns: ["submitted_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_progress_logs_validated_by_fkey"
            columns: ["validated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_record_assignments: {
        Row: {
          academic_role: string
          assigned_at: string
          assigned_by: string | null
          created_at: string
          fyp_record_id: string
          id: string
          is_active: boolean
          lecturer_id: string
          updated_at: string
        }
        Insert: {
          academic_role: string
          assigned_at?: string
          assigned_by?: string | null
          created_at?: string
          fyp_record_id: string
          id?: string
          is_active?: boolean
          lecturer_id: string
          updated_at?: string
        }
        Update: {
          academic_role?: string
          assigned_at?: string
          assigned_by?: string | null
          created_at?: string
          fyp_record_id?: string
          id?: string
          is_active?: boolean
          lecturer_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_record_assignments_assigned_by_fkey"
            columns: ["assigned_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_record_assignments_fyp_record_id_fkey"
            columns: ["fyp_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_record_assignments_lecturer_id_fkey"
            columns: ["lecturer_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_records: {
        Row: {
          academic_semester_id: string
          co_supervisor_id: string | null
          created_at: string
          current_course_code: string
          examiner_id: string | null
          external_industry_partner: string | null
          id: string
          main_supervisor_id: string | null
          matric_id: string | null
          previous_record_id: string | null
          programme_code: string
          project_description: string | null
          project_title: string | null
          project_type: string | null
          student_id: string
          updated_at: string
          workflow_status: string
        }
        Insert: {
          academic_semester_id: string
          co_supervisor_id?: string | null
          created_at?: string
          current_course_code: string
          examiner_id?: string | null
          external_industry_partner?: string | null
          id?: string
          main_supervisor_id?: string | null
          matric_id?: string | null
          previous_record_id?: string | null
          programme_code: string
          project_description?: string | null
          project_title?: string | null
          project_type?: string | null
          student_id: string
          updated_at?: string
          workflow_status?: string
        }
        Update: {
          academic_semester_id?: string
          co_supervisor_id?: string | null
          created_at?: string
          current_course_code?: string
          examiner_id?: string | null
          external_industry_partner?: string | null
          id?: string
          main_supervisor_id?: string | null
          matric_id?: string | null
          previous_record_id?: string | null
          programme_code?: string
          project_description?: string | null
          project_title?: string | null
          project_type?: string | null
          student_id?: string
          updated_at?: string
          workflow_status?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_records_academic_semester_id_fkey"
            columns: ["academic_semester_id"]
            isOneToOne: false
            referencedRelation: "academic_semesters"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_records_co_supervisor_id_fkey"
            columns: ["co_supervisor_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_records_current_course_code_fkey"
            columns: ["current_course_code"]
            isOneToOne: false
            referencedRelation: "academic_courses"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "fyp_records_examiner_id_fkey"
            columns: ["examiner_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_records_main_supervisor_id_fkey"
            columns: ["main_supervisor_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_records_previous_record_id_fkey"
            columns: ["previous_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_records_student_id_fkey"
            columns: ["student_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_report_submissions: {
        Row: {
          created_at: string
          file_url: string
          fyp_record_id: string
          id: string
          report_type: string
          review_comment: string | null
          reviewed_at: string | null
          reviewed_by: string | null
          similarity_index: number | null
          status: string
          submitted_at: string
          submitted_by: string | null
          updated_at: string
          version: number
        }
        Insert: {
          created_at?: string
          file_url: string
          fyp_record_id: string
          id?: string
          report_type: string
          review_comment?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          similarity_index?: number | null
          status?: string
          submitted_at?: string
          submitted_by?: string | null
          updated_at?: string
          version?: number
        }
        Update: {
          created_at?: string
          file_url?: string
          fyp_record_id?: string
          id?: string
          report_type?: string
          review_comment?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          similarity_index?: number | null
          status?: string
          submitted_at?: string
          submitted_by?: string | null
          updated_at?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "fyp_report_submissions_fyp_record_id_fkey"
            columns: ["fyp_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_report_submissions_reviewed_by_fkey"
            columns: ["reviewed_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_report_submissions_submitted_by_fkey"
            columns: ["submitted_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      fyp_rubric_templates: {
        Row: {
          created_at: string
          criteria: Json
          form_code: string
          id: string
          is_active: boolean
          rubric_code: string
          rubric_name: string
          updated_at: string
          version: number
        }
        Insert: {
          created_at?: string
          criteria?: Json
          form_code: string
          id?: string
          is_active?: boolean
          rubric_code: string
          rubric_name: string
          updated_at?: string
          version?: number
        }
        Update: {
          created_at?: string
          criteria?: Json
          form_code?: string
          id?: string
          is_active?: boolean
          rubric_code?: string
          rubric_name?: string
          updated_at?: string
          version?: number
        }
        Relationships: []
      }
      fyp_supervision_requests: {
        Row: {
          created_at: string
          decided_at: string | null
          decided_by: string | null
          decision_reason: string | null
          fyp_record_id: string
          id: string
          preferred_supervisor_id: string | null
          rationale: string | null
          status: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          decided_at?: string | null
          decided_by?: string | null
          decision_reason?: string | null
          fyp_record_id: string
          id?: string
          preferred_supervisor_id?: string | null
          rationale?: string | null
          status?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          decided_at?: string | null
          decided_by?: string | null
          decision_reason?: string | null
          fyp_record_id?: string
          id?: string
          preferred_supervisor_id?: string | null
          rationale?: string | null
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fyp_supervision_requests_decided_by_fkey"
            columns: ["decided_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_supervision_requests_fyp_record_id_fkey"
            columns: ["fyp_record_id"]
            isOneToOne: false
            referencedRelation: "fyp_records"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fyp_supervision_requests_preferred_supervisor_id_fkey"
            columns: ["preferred_supervisor_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      import_award_candidates: {
        Row: {
          award_category: string
          comparison_status: string
          created_at: string
          id: string
          import_id: string
          is_skip: boolean
          programme_code: string | null
          project_title: string
          row_number: number
          supervisor_display_name: string | null
          team_display_name: string | null
        }
        Insert: {
          award_category: string
          comparison_status?: string
          created_at?: string
          id?: string
          import_id: string
          is_skip?: boolean
          programme_code?: string | null
          project_title: string
          row_number: number
          supervisor_display_name?: string | null
          team_display_name?: string | null
        }
        Update: {
          award_category?: string
          comparison_status?: string
          created_at?: string
          id?: string
          import_id?: string
          is_skip?: boolean
          programme_code?: string | null
          project_title?: string
          row_number?: number
          supervisor_display_name?: string | null
          team_display_name?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "import_award_candidates_import_id_fkey"
            columns: ["import_id"]
            isOneToOne: false
            referencedRelation: "imports"
            referencedColumns: ["id"]
          },
        ]
      }
      import_privacy_skips: {
        Row: {
          category: string
          created_at: string
          field_name: string
          id: string
          import_id: string
          masked_preview: string | null
          reason: string
          row_number: number
          sheet_name: string
        }
        Insert: {
          category: string
          created_at?: string
          field_name: string
          id?: string
          import_id: string
          masked_preview?: string | null
          reason: string
          row_number: number
          sheet_name: string
        }
        Update: {
          category?: string
          created_at?: string
          field_name?: string
          id?: string
          import_id?: string
          masked_preview?: string | null
          reason?: string
          row_number?: number
          sheet_name?: string
        }
        Relationships: [
          {
            foreignKeyName: "import_privacy_skips_import_id_fkey"
            columns: ["import_id"]
            isOneToOne: false
            referencedRelation: "imports"
            referencedColumns: ["id"]
          },
        ]
      }
      import_review_decisions: {
        Row: {
          action: string
          candidate_id: string
          candidate_type: string
          created_at: string
          decision_version: number
          edited_public_data: Json | null
          id: string
          import_id: string
          notes: string | null
          reviewed_at: string | null
          reviewed_by: string | null
          target_public_record_id: string | null
          updated_at: string
        }
        Insert: {
          action: string
          candidate_id: string
          candidate_type: string
          created_at?: string
          decision_version?: number
          edited_public_data?: Json | null
          id?: string
          import_id: string
          notes?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          target_public_record_id?: string | null
          updated_at?: string
        }
        Update: {
          action?: string
          candidate_id?: string
          candidate_type?: string
          created_at?: string
          decision_version?: number
          edited_public_data?: Json | null
          id?: string
          import_id?: string
          notes?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          target_public_record_id?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "import_review_decisions_import_id_fkey"
            columns: ["import_id"]
            isOneToOne: false
            referencedRelation: "imports"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "import_review_decisions_reviewed_by_fkey"
            columns: ["reviewed_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      import_schedule_candidates: {
        Row: {
          access_type: string
          audience: string | null
          comparison_status: string
          created_at: string
          day_label: string | null
          description: string | null
          end_at: string | null
          event_date: string | null
          id: string
          import_id: string
          is_duplicate: boolean
          is_overlapping: boolean
          overlap_details: string | null
          raw_end_str: string | null
          raw_start_str: string | null
          row_number: number
          start_at: string | null
          title: string
          venue: string | null
        }
        Insert: {
          access_type?: string
          audience?: string | null
          comparison_status?: string
          created_at?: string
          day_label?: string | null
          description?: string | null
          end_at?: string | null
          event_date?: string | null
          id?: string
          import_id: string
          is_duplicate?: boolean
          is_overlapping?: boolean
          overlap_details?: string | null
          raw_end_str?: string | null
          raw_start_str?: string | null
          row_number: number
          start_at?: string | null
          title: string
          venue?: string | null
        }
        Update: {
          access_type?: string
          audience?: string | null
          comparison_status?: string
          created_at?: string
          day_label?: string | null
          description?: string | null
          end_at?: string | null
          event_date?: string | null
          id?: string
          import_id?: string
          is_duplicate?: boolean
          is_overlapping?: boolean
          overlap_details?: string | null
          raw_end_str?: string | null
          raw_start_str?: string | null
          row_number?: number
          start_at?: string | null
          title?: string
          venue?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "import_schedule_candidates_import_id_fkey"
            columns: ["import_id"]
            isOneToOne: false
            referencedRelation: "imports"
            referencedColumns: ["id"]
          },
        ]
      }
      import_validation_issues: {
        Row: {
          created_at: string
          id: string
          import_id: string
          issue_type: string
          message: string
          row_number: number
          severity: string
          worksheet_name: string
        }
        Insert: {
          created_at?: string
          id?: string
          import_id: string
          issue_type: string
          message: string
          row_number: number
          severity: string
          worksheet_name: string
        }
        Update: {
          created_at?: string
          id?: string
          import_id?: string
          issue_type?: string
          message?: string
          row_number?: number
          severity?: string
          worksheet_name?: string
        }
        Relationships: [
          {
            foreignKeyName: "import_validation_issues_import_id_fkey"
            columns: ["import_id"]
            isOneToOne: false
            referencedRelation: "imports"
            referencedColumns: ["id"]
          },
        ]
      }
      imports: {
        Row: {
          candidates_count: number
          completed_at: string | null
          created_at: string
          event_id: string | null
          file_name: string
          file_size_bytes: number
          id: string
          status: string
          summary: Json
          updated_at: string
          uploaded_by: string
          warnings_count: number
        }
        Insert: {
          candidates_count?: number
          completed_at?: string | null
          created_at?: string
          event_id?: string | null
          file_name: string
          file_size_bytes?: number
          id?: string
          status?: string
          summary?: Json
          updated_at?: string
          uploaded_by: string
          warnings_count?: number
        }
        Update: {
          candidates_count?: number
          completed_at?: string | null
          created_at?: string
          event_id?: string | null
          file_name?: string
          file_size_bytes?: number
          id?: string
          status?: string
          summary?: Json
          updated_at?: string
          uploaded_by?: string
          warnings_count?: number
        }
        Relationships: [
          {
            foreignKeyName: "imports_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "imports_uploaded_by_fkey"
            columns: ["uploaded_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      lecturer_assignments: {
        Row: {
          assigned_at: string
          assigned_by: string | null
          event_id: string
          id: string
          lecturer_display_name: string | null
          lecturer_email: string | null
          lecturer_id: string
          project_id: string
          role: string
          status: string
          updated_at: string
        }
        Insert: {
          assigned_at?: string
          assigned_by?: string | null
          event_id: string
          id?: string
          lecturer_display_name?: string | null
          lecturer_email?: string | null
          lecturer_id: string
          project_id: string
          role: string
          status?: string
          updated_at?: string
        }
        Update: {
          assigned_at?: string
          assigned_by?: string | null
          event_id?: string
          id?: string
          lecturer_display_name?: string | null
          lecturer_email?: string | null
          lecturer_id?: string
          project_id?: string
          role?: string
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "lecturer_assignments_assigned_by_fkey"
            columns: ["assigned_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lecturer_assignments_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lecturer_assignments_lecturer_id_fkey"
            columns: ["lecturer_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lecturer_assignments_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      oauth_states: {
        Row: {
          created_at: string
          expires_at: string
          platform: string
          provider: string | null
          return_to: string | null
          state: string
          used: boolean | null
          user_id: string
        }
        Insert: {
          created_at?: string
          expires_at?: string
          platform: string
          provider?: string | null
          return_to?: string | null
          state?: string
          used?: boolean | null
          user_id: string
        }
        Update: {
          created_at?: string
          expires_at?: string
          platform?: string
          provider?: string | null
          return_to?: string | null
          state?: string
          used?: boolean | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "oauth_states_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["uid"]
          },
        ]
      }
      processing_jobs: {
        Row: {
          content_type: string | null
          created_at: string
          id: string
          metadata: Json | null
          size_bytes: number | null
          source_uri: string | null
          status: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          content_type?: string | null
          created_at?: string
          id: string
          metadata?: Json | null
          size_bytes?: number | null
          source_uri?: string | null
          status?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          content_type?: string | null
          created_at?: string
          id?: string
          metadata?: Json | null
          size_bytes?: number | null
          source_uri?: string | null
          status?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "processing_jobs_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["uid"]
          },
        ]
      }
      profile_academic_roles: {
        Row: {
          created_at: string
          id: string
          is_active: boolean
          profile_id: string
          programme_code: string
          role_code: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_active?: boolean
          profile_id: string
          programme_code?: string
          role_code: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          is_active?: boolean
          profile_id?: string
          programme_code?: string
          role_code?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "profile_academic_roles_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          created_at: string
          display_name: string
          email: string
          id: string
          is_active: boolean
          role: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          display_name: string
          email: string
          id: string
          is_active?: boolean
          role: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          display_name?: string
          email?: string
          id?: string
          is_active?: boolean
          role?: string
          updated_at?: string
        }
        Relationships: []
      }
      projects: {
        Row: {
          abstract: string | null
          booth_id: string | null
          booth_number: string | null
          booth_zone: string | null
          category: string | null
          cover_image_url: string | null
          created_at: string
          demo_url: string | null
          event_id: string
          examiner_display_name: string | null
          featured: boolean
          id: string
          industry_candidate: boolean
          matric_id: string | null
          presentation_day: string | null
          programme_code: string | null
          programme_name: string | null
          publication_status: string
          repository_url: string | null
          short_description: string | null
          slug: string
          student_team: Json
          supervisor_display_name: string | null
          team_display_name: string | null
          tech_tags: Json
          title: string
          updated_at: string
          video_url: string | null
        }
        Insert: {
          abstract?: string | null
          booth_id?: string | null
          booth_number?: string | null
          booth_zone?: string | null
          category?: string | null
          cover_image_url?: string | null
          created_at?: string
          demo_url?: string | null
          event_id: string
          examiner_display_name?: string | null
          featured?: boolean
          id?: string
          industry_candidate?: boolean
          matric_id?: string | null
          presentation_day?: string | null
          programme_code?: string | null
          programme_name?: string | null
          publication_status?: string
          repository_url?: string | null
          short_description?: string | null
          slug: string
          student_team?: Json
          supervisor_display_name?: string | null
          team_display_name?: string | null
          tech_tags?: Json
          title: string
          updated_at?: string
          video_url?: string | null
        }
        Update: {
          abstract?: string | null
          booth_id?: string | null
          booth_number?: string | null
          booth_zone?: string | null
          category?: string | null
          cover_image_url?: string | null
          created_at?: string
          demo_url?: string | null
          event_id?: string
          examiner_display_name?: string | null
          featured?: boolean
          id?: string
          industry_candidate?: boolean
          matric_id?: string | null
          presentation_day?: string | null
          programme_code?: string | null
          programme_name?: string | null
          publication_status?: string
          repository_url?: string | null
          short_description?: string | null
          slug?: string
          student_team?: Json
          supervisor_display_name?: string | null
          team_display_name?: string | null
          tech_tags?: Json
          title?: string
          updated_at?: string
          video_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_projects_booth"
            columns: ["booth_id"]
            isOneToOne: false
            referencedRelation: "booths"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projects_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      schedule_items: {
        Row: {
          access_type: string
          audience: string | null
          created_at: string
          day_label: string | null
          description: string | null
          end_at: string
          event_date: string
          event_id: string
          id: string
          publication_status: string
          start_at: string
          title: string
          updated_at: string
          venue: string | null
        }
        Insert: {
          access_type?: string
          audience?: string | null
          created_at?: string
          day_label?: string | null
          description?: string | null
          end_at: string
          event_date: string
          event_id: string
          id?: string
          publication_status?: string
          start_at: string
          title: string
          updated_at?: string
          venue?: string | null
        }
        Update: {
          access_type?: string
          audience?: string | null
          created_at?: string
          day_label?: string | null
          description?: string | null
          end_at?: string
          event_date?: string
          event_id?: string
          id?: string
          publication_status?: string
          start_at?: string
          title?: string
          updated_at?: string
          venue?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "schedule_items_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      schedules: {
        Row: {
          content_id: string | null
          created_at: string
          id: string
          scheduled_at: string | null
          status: string | null
        }
        Insert: {
          content_id?: string | null
          created_at?: string
          id?: string
          scheduled_at?: string | null
          status?: string | null
        }
        Update: {
          content_id?: string | null
          created_at?: string
          id?: string
          scheduled_at?: string | null
          status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "schedules_content_id_fkey"
            columns: ["content_id"]
            isOneToOne: false
            referencedRelation: "content"
            referencedColumns: ["id"]
          },
        ]
      }
      settings: {
        Row: {
          key: string
          updated_at: string
          updated_by: string | null
          value: Json
        }
        Insert: {
          key: string
          updated_at?: string
          updated_by?: string | null
          value: Json
        }
        Update: {
          key?: string
          updated_at?: string
          updated_by?: string | null
          value?: Json
        }
        Relationships: [
          {
            foreignKeyName: "settings_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      site_settings: {
        Row: {
          created_at: string
          hmac_secret: string | null
          id: string
          is_active: boolean | null
          updated_at: string
          user_id: string
          webhook_url: string | null
        }
        Insert: {
          created_at?: string
          hmac_secret?: string | null
          id?: string
          is_active?: boolean | null
          updated_at?: string
          user_id: string
          webhook_url?: string | null
        }
        Update: {
          created_at?: string
          hmac_secret?: string | null
          id?: string
          is_active?: boolean | null
          updated_at?: string
          user_id?: string
          webhook_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "site_settings_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["uid"]
          },
        ]
      }
      student_project_visits: {
        Row: {
          assignment_id: string
          created_at: string
          event_id: string
          id: string
          lecturer_id: string
          project_id: string
          source: string
          status: string
          updated_at: string
          visit_note: string | null
          visit_role: string
          visited_at: string
          void_reason: string | null
          voided_at: string | null
          voided_by: string | null
          voided_by_role: string | null
        }
        Insert: {
          assignment_id: string
          created_at?: string
          event_id: string
          id?: string
          lecturer_id: string
          project_id: string
          source?: string
          status?: string
          updated_at?: string
          visit_note?: string | null
          visit_role: string
          visited_at?: string
          void_reason?: string | null
          voided_at?: string | null
          voided_by?: string | null
          voided_by_role?: string | null
        }
        Update: {
          assignment_id?: string
          created_at?: string
          event_id?: string
          id?: string
          lecturer_id?: string
          project_id?: string
          source?: string
          status?: string
          updated_at?: string
          visit_note?: string | null
          visit_role?: string
          visited_at?: string
          void_reason?: string | null
          voided_at?: string | null
          voided_by?: string | null
          voided_by_role?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "student_project_visits_assignment_id_fkey"
            columns: ["assignment_id"]
            isOneToOne: false
            referencedRelation: "lecturer_assignments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "student_project_visits_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "student_project_visits_lecturer_id_fkey"
            columns: ["lecturer_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "student_project_visits_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "student_project_visits_voided_by_fkey"
            columns: ["voided_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      telemetry: {
        Row: {
          content_id: string | null
          created_at: string
          event_type: string | null
          id: string
          metadata: Json | null
        }
        Insert: {
          content_id?: string | null
          created_at?: string
          event_type?: string | null
          id?: string
          metadata?: Json | null
        }
        Update: {
          content_id?: string | null
          created_at?: string
          event_type?: string | null
          id?: string
          metadata?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "telemetry_content_id_fkey"
            columns: ["content_id"]
            isOneToOne: false
            referencedRelation: "content"
            referencedColumns: ["id"]
          },
        ]
      }
      users: {
        Row: {
          created_at: string
          display_name: string | null
          email: string | null
          photo_url: string | null
          role: string | null
          settings: Json | null
          uid: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          display_name?: string | null
          email?: string | null
          photo_url?: string | null
          role?: string | null
          settings?: Json | null
          uid: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          display_name?: string | null
          email?: string | null
          photo_url?: string | null
          role?: string | null
          settings?: Json | null
          uid?: string
          updated_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      admin_override_fyp_record_field: {
        Args: {
          p_field: string
          p_fyp_record_id: string
          p_reason: string
          p_value: string
        }
        Returns: {
          academic_semester_id: string
          co_supervisor_id: string | null
          created_at: string
          current_course_code: string
          examiner_id: string | null
          external_industry_partner: string | null
          id: string
          main_supervisor_id: string | null
          matric_id: string | null
          previous_record_id: string | null
          programme_code: string
          project_description: string | null
          project_title: string | null
          project_type: string | null
          student_id: string
          updated_at: string
          workflow_status: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_records"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      archive_fyp_record: {
        Args: { p_fyp_record_id: string; p_reason?: string }
        Returns: {
          academic_semester_id: string
          co_supervisor_id: string | null
          created_at: string
          current_course_code: string
          examiner_id: string | null
          external_industry_partner: string | null
          id: string
          main_supervisor_id: string | null
          matric_id: string | null
          previous_record_id: string | null
          programme_code: string
          project_description: string | null
          project_title: string | null
          project_type: string | null
          student_id: string
          updated_at: string
          workflow_status: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_records"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      assign_examiner: {
        Args: { p_examiner_id: string; p_fyp_record_id: string }
        Returns: {
          academic_semester_id: string
          co_supervisor_id: string | null
          created_at: string
          current_course_code: string
          examiner_id: string | null
          external_industry_partner: string | null
          id: string
          main_supervisor_id: string | null
          matric_id: string | null
          previous_record_id: string | null
          programme_code: string
          project_description: string | null
          project_title: string | null
          project_type: string | null
          student_id: string
          updated_at: string
          workflow_status: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_records"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      assign_supervisor_to_fyp_record: {
        Args: {
          p_fyp_record_id: string
          p_role?: string
          p_supervisor_id: string
        }
        Returns: {
          academic_semester_id: string
          co_supervisor_id: string | null
          created_at: string
          current_course_code: string
          examiner_id: string | null
          external_industry_partner: string | null
          id: string
          main_supervisor_id: string | null
          matric_id: string | null
          previous_record_id: string | null
          programme_code: string
          project_description: string | null
          project_title: string | null
          project_type: string | null
          student_id: string
          updated_at: string
          workflow_status: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_records"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      can_edit_fyp_record: {
        Args: { p_fyp_record_id: string }
        Returns: boolean
      }
      can_manage_fyp_offering: {
        Args: { p_offering_id: string }
        Returns: boolean
      }
      can_publish_fyp_record_to_expo: {
        Args: { p_fyp_record_id: string }
        Returns: boolean
      }
      can_read_assignment: {
        Args: { p_assignment_id: string }
        Returns: boolean
      }
      can_read_fyp_record: {
        Args: { p_fyp_record_id: string }
        Returns: boolean
      }
      can_read_project: { Args: { p_project_id: string }; Returns: boolean }
      cleanup_oauth_states: { Args: never; Returns: undefined }
      confirm_correction: {
        Args: {
          p_confirmation_status: string
          p_correction_item_id: string
          p_notes?: string
        }
        Returns: {
          comment: string | null
          confirmed_at: string
          confirmed_by: string
          correction_item_id: string
          created_at: string
          id: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_correction_confirmations"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      confirm_fyp_corrections: {
        Args: { p_comment?: string; p_correction_item_id: string }
        Returns: {
          comment: string | null
          confirmed_at: string
          confirmed_by: string
          correction_item_id: string
          created_at: string
          id: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_correction_confirmations"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      create_correction_item: {
        Args: {
          p_correction_text: string
          p_form_submission_id: string
          p_fyp_record_id: string
          p_severity?: string
        }
        Returns: {
          created_at: string
          created_by: string | null
          description: string
          form_submission_id: string | null
          fyp_record_id: string
          id: string
          item_code: string
          severity: string
          status: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_correction_items"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      create_fyp_record: {
        Args: {
          p_academic_semester_id: string
          p_current_course_code: string
          p_external_industry_partner?: string
          p_matric_id?: string
          p_previous_record_id?: string
          p_programme_code: string
          p_project_description?: string
          p_project_title?: string
          p_project_type?: string
          p_student_id: string
        }
        Returns: {
          academic_semester_id: string
          co_supervisor_id: string | null
          created_at: string
          current_course_code: string
          examiner_id: string | null
          external_industry_partner: string | null
          id: string
          main_supervisor_id: string | null
          matric_id: string | null
          previous_record_id: string | null
          programme_code: string
          project_description: string | null
          project_title: string | null
          project_type: string | null
          student_id: string
          updated_at: string
          workflow_status: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_records"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      create_lecturer_account_profile: {
        Args: { p_display_name: string; p_email: string; p_user_id: string }
        Returns: {
          created_at: string
          display_name: string
          email: string
          id: string
          is_active: boolean
          role: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "profiles"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      create_or_update_milestone: {
        Args: {
          p_description?: string
          p_fyp_record_id: string
          p_milestone_code: string
          p_milestone_title: string
          p_status?: string
          p_target_date?: string
        }
        Returns: {
          completed_at: string | null
          created_at: string
          description: string | null
          fyp_record_id: string
          id: string
          milestone_code: string
          milestone_title: string
          status: string
          target_date: string | null
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_milestones"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      create_student_account_profile: {
        Args: {
          p_display_name: string
          p_email: string
          p_matric_id?: string
          p_programme_code: string
          p_user_id: string
        }
        Returns: {
          created_at: string
          display_name: string
          email: string
          id: string
          is_active: boolean
          role: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "profiles"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      current_event_is_public: {
        Args: { p_event_id: string }
        Returns: boolean
      }
      current_user_role: { Args: never; Returns: string }
      decide_supervision_request: {
        Args: {
          p_decision: string
          p_decision_reason?: string
          p_request_id: string
        }
        Returns: {
          created_at: string
          decided_at: string | null
          decided_by: string | null
          decision_reason: string | null
          fyp_record_id: string
          id: string
          preferred_supervisor_id: string | null
          rationale: string | null
          status: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_supervision_requests"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      finalize_marks: {
        Args: {
          p_component_breakdown: Json
          p_course_code: string
          p_fyp_record_id: string
        }
        Returns: {
          academic_semester_id: string
          course_code: string
          created_at: string
          export_payload: Json | null
          finalized_at: string | null
          finalized_by: string | null
          fyp_record_id: string
          grade: string | null
          id: string
          is_finalized: boolean
          marks: Json
          updated_at: string
          weighted_total: number
        }
        SetofOptions: {
          from: "*"
          to: "fyp_marks_summaries"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      get_content_filtered: {
        Args: {
          filter_limit?: number
          filter_owner_id?: string
          filter_status?: string
        }
        Returns: {
          assets: Json
          created_at: string
          description: string
          destination_posts: Json
          duration: number
          id: string
          owner_id: string
          scheduled_at: string
          selected_destinations: string[]
          thumbnail_url: string
          title: string
          type: string
          updated_at: string
          version: number
          video_url: string
          workflow_status: string
        }[]
      }
      get_dashboard_stats: {
        Args: { input_user_id: string }
        Returns: {
          draft_count: number
          processing_count: number
          ready_for_review_count: number
          released_count: number
          total_channels: number
          total_content: number
        }[]
      }
      grant_milestone_extension: {
        Args: {
          p_decision?: string
          p_milestone_id: string
          p_reason?: string
          p_requested_by?: string
          p_requested_due_date?: string
        }
        Returns: {
          created_at: string
          decided_at: string | null
          decided_by: string | null
          decision_comment: string | null
          id: string
          milestone_id: string
          reason: string
          requested_by: string
          requested_due_date: string
          status: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_milestone_extensions"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      has_academic_role: { Args: { p_role_code: string }; Returns: boolean }
      has_academic_role_for_programme: {
        Args: { p_programme_code: string; p_role_code: string }
        Returns: boolean
      }
      is_active_fyp_student: {
        Args: { p_fyp_record_id: string }
        Returns: boolean
      }
      is_active_profile: { Args: never; Returns: boolean }
      is_admin: { Args: never; Returns: boolean }
      is_assigned_to_fyp_record: {
        Args: { p_fyp_record_id: string; p_role: string }
        Returns: boolean
      }
      is_csp_lecturer: { Args: { p_course_code: string }; Returns: boolean }
      is_editor: { Args: never; Returns: boolean }
      is_fyp_coordinator: { Args: never; Returns: boolean }
      is_lecturer: { Args: never; Returns: boolean }
      list_fyp_coordinators: {
        Args: never
        Returns: {
          display_name: string
          email: string
          id: string
        }[]
      }
      list_fyp_staff: {
        Args: { p_role_codes?: string[] }
        Returns: {
          display_name: string
          email: string
          id: string
        }[]
      }
      list_fyp_students: {
        Args: never
        Returns: {
          display_name: string
          email: string
          id: string
          matric_id: string
          programme_code: string
        }[]
      }
      mark_student_project_visited: {
        Args: { p_assignment_id: string; p_visit_note?: string }
        Returns: {
          assignment_id: string
          created_at: string
          event_id: string
          id: string
          lecturer_id: string
          project_id: string
          source: string
          status: string
          updated_at: string
          visit_note: string | null
          visit_role: string
          visited_at: string
          void_reason: string | null
          voided_at: string | null
          voided_by: string | null
          voided_by_role: string | null
        }
        SetofOptions: {
          from: "*"
          to: "student_project_visits"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      prepare_expo_publication: {
        Args: { p_event_id: string; p_fyp_record_id: string; p_payload?: Json }
        Returns: {
          created_at: string
          event_id: string
          fyp_record_id: string
          id: string
          payload: Json
          prepared_at: string | null
          prepared_by: string | null
          published_at: string | null
          published_by: string | null
          published_project_id: string | null
          status: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_expo_publications"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      publish_approved_import_changes: {
        Args: { p_import_id: string }
        Returns: Json
      }
      publish_fyp_record_to_expo: {
        Args: { p_publication_id: string }
        Returns: {
          created_at: string
          event_id: string
          fyp_record_id: string
          id: string
          payload: Json
          prepared_at: string | null
          prepared_by: string | null
          published_at: string | null
          published_by: string | null
          published_project_id: string | null
          status: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_expo_publications"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      publish_scheduled_content: { Args: never; Returns: undefined }
      review_progress_log: {
        Args: {
          p_decision: string
          p_progress_log_id: string
          p_validation_comment?: string
        }
        Returns: {
          challenges: string | null
          created_at: string
          fyp_record_id: string
          id: string
          next_plan: string | null
          progress_date: string
          status: string
          submitted_at: string | null
          submitted_by: string | null
          summary: string
          updated_at: string
          validated_at: string | null
          validated_by: string | null
          validation_comment: string | null
          week_number: number
        }
        SetofOptions: {
          from: "*"
          to: "fyp_progress_logs"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      save_lean_canvas: {
        Args: { p_blocks?: Json; p_fyp_record_id: string }
        Returns: {
          blocks: Json
          canvas_version: number
          created_at: string
          fyp_record_id: string
          id: string
          is_latest: boolean
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_lean_canvases"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      schedule_presentation_slot: {
        Args: {
          p_end_at: string
          p_fyp_record_id: string
          p_room?: string
          p_session_id: string
          p_slot_number: number
          p_start_at: string
        }
        Returns: {
          created_at: string
          end_at: string
          fyp_record_id: string
          id: string
          room: string | null
          session_id: string
          slot_number: number
          start_at: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_presentation_slots"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      submit_deliverable: {
        Args: {
          p_deliverable_type: string
          p_description?: string
          p_file_url?: string
          p_fyp_record_id: string
          p_title: string
        }
        Returns: {
          created_at: string
          deliverable_type: string
          description: string | null
          file_url: string | null
          fyp_record_id: string
          id: string
          is_required: boolean
          submitted_at: string | null
          submitted_by: string | null
          title: string
          updated_at: string
          version: number
        }
        SetofOptions: {
          from: "*"
          to: "fyp_deliverables"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      submit_form_evaluation: {
        Args: {
          p_comments?: string
          p_criteria_scores: Json
          p_decision?: string
          p_form_submission_id: string
        }
        Returns: {
          comments: string | null
          created_at: string
          evaluated_at: string | null
          evaluator_id: string
          form_submission_id: string
          id: string
          rubric_template_id: string | null
          scores: Json
          status: string
          updated_at: string
          weighted_total: number
        }
        SetofOptions: {
          from: "*"
          to: "fyp_form_evaluations"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      submit_fyp_form: {
        Args: {
          p_file_url?: string
          p_form_code: string
          p_fyp_record_id: string
          p_payload: Json
          p_similarity_index?: number
        }
        Returns: {
          created_at: string
          form_code: string
          form_version: number
          fyp_record_id: string
          id: string
          payload: Json
          status: string
          submitted_at: string | null
          submitted_by: string | null
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_form_submissions"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      submit_progress_log: {
        Args: {
          p_challenges?: string
          p_fyp_record_id: string
          p_next_plan?: string
          p_progress_date?: string
          p_summary: string
          p_week_number: number
        }
        Returns: {
          challenges: string | null
          created_at: string
          fyp_record_id: string
          id: string
          next_plan: string | null
          progress_date: string
          status: string
          submitted_at: string | null
          submitted_by: string | null
          summary: string
          updated_at: string
          validated_at: string | null
          validated_by: string | null
          validation_comment: string | null
          week_number: number
        }
        SetofOptions: {
          from: "*"
          to: "fyp_progress_logs"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      submit_report_version: {
        Args: {
          p_file_url: string
          p_fyp_record_id: string
          p_report_type: string
          p_similarity_index?: number
        }
        Returns: {
          created_at: string
          file_url: string
          fyp_record_id: string
          id: string
          report_type: string
          review_comment: string | null
          reviewed_at: string | null
          reviewed_by: string | null
          similarity_index: number | null
          status: string
          submitted_at: string
          submitted_by: string | null
          updated_at: string
          version: number
        }
        SetofOptions: {
          from: "*"
          to: "fyp_report_submissions"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      submit_supervision_request: {
        Args: {
          p_fyp_record_id: string
          p_preferred_supervisor_id?: string
          p_rationale?: string
        }
        Returns: {
          created_at: string
          decided_at: string | null
          decided_by: string | null
          decision_reason: string | null
          fyp_record_id: string
          id: string
          preferred_supervisor_id: string | null
          rationale: string | null
          status: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_supervision_requests"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      update_event_configuration: {
        Args: { p_event_id: string; p_payload: Json }
        Returns: {
          created_at: string
          daily_hours: string | null
          description: string | null
          end_at: string
          faq_items: Json
          hero_image_url: string | null
          id: string
          location_details: string | null
          map_url: string | null
          objectives: Json
          poster_url: string | null
          public_contact_email: string | null
          publication_status: string
          session_label: string | null
          slug: string
          start_at: string
          status: string
          title: string
          updated_at: string
          updated_by: string | null
          venue: string | null
        }
        SetofOptions: {
          from: "*"
          to: "events"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      update_fyp_record_field: {
        Args: { p_field: string; p_fyp_record_id: string; p_value: string }
        Returns: {
          academic_semester_id: string
          co_supervisor_id: string | null
          created_at: string
          current_course_code: string
          examiner_id: string | null
          external_industry_partner: string | null
          id: string
          main_supervisor_id: string | null
          matric_id: string | null
          previous_record_id: string | null
          programme_code: string
          project_description: string | null
          project_title: string | null
          project_type: string | null
          student_id: string
          updated_at: string
          workflow_status: string
        }
        SetofOptions: {
          from: "*"
          to: "fyp_records"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      validate_progress_log: {
        Args: {
          p_progress_log_id: string
          p_status: string
          p_validation_comment?: string
        }
        Returns: {
          challenges: string | null
          created_at: string
          fyp_record_id: string
          id: string
          next_plan: string | null
          progress_date: string
          status: string
          submitted_at: string | null
          submitted_by: string | null
          summary: string
          updated_at: string
          validated_at: string | null
          validated_by: string | null
          validation_comment: string | null
          week_number: number
        }
        SetofOptions: {
          from: "*"
          to: "fyp_progress_logs"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      void_student_project_visit: {
        Args: { p_reason: string; p_visit_id: string }
        Returns: {
          assignment_id: string
          created_at: string
          event_id: string
          id: string
          lecturer_id: string
          project_id: string
          source: string
          status: string
          updated_at: string
          visit_note: string | null
          visit_role: string
          visited_at: string
          void_reason: string | null
          voided_at: string | null
          voided_by: string | null
          voided_by_role: string | null
        }
        SetofOptions: {
          from: "*"
          to: "student_project_visits"
          isOneToOne: true
          isSetofReturn: false
        }
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const

