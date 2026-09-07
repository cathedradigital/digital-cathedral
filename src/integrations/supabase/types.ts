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
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      bible_books: {
        Row: {
          abbrev: string
          canonical_type: string | null
          chapters_count: number
          created_at: string
          id: string
          name: string
          testament: string | null
          updated_at: string
        }
        Insert: {
          abbrev: string
          canonical_type?: string | null
          chapters_count: number
          created_at?: string
          id?: string
          name: string
          testament?: string | null
          updated_at?: string
        }
        Update: {
          abbrev?: string
          canonical_type?: string | null
          chapters_count?: number
          created_at?: string
          id?: string
          name?: string
          testament?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      bible_chapters: {
        Row: {
          book_id: string
          created_at: string
          id: string
          number: number
          updated_at: string
        }
        Insert: {
          book_id: string
          created_at?: string
          id?: string
          number: number
          updated_at?: string
        }
        Update: {
          book_id?: string
          created_at?: string
          id?: string
          number?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "bible_chapters_book_id_fkey"
            columns: ["book_id"]
            isOneToOne: false
            referencedRelation: "bible_books"
            referencedColumns: ["id"]
          },
        ]
      }
      bible_verses: {
        Row: {
          chapter_id: string
          created_at: string
          id: string
          number: number
          text: string
          updated_at: string
        }
        Insert: {
          chapter_id: string
          created_at?: string
          id?: string
          number: number
          text: string
          updated_at?: string
        }
        Update: {
          chapter_id?: string
          created_at?: string
          id?: string
          number?: number
          text?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "bible_verses_chapter_id_fkey"
            columns: ["chapter_id"]
            isOneToOne: false
            referencedRelation: "bible_chapters"
            referencedColumns: ["id"]
          },
        ]
      }
      catechism_official: {
        Row: {
          content: string
          created_at: string
          paragraph: number
          updated_at: string
        }
        Insert: {
          content: string
          created_at?: string
          paragraph: number
          updated_at?: string
        }
        Update: {
          content?: string
          created_at?: string
          paragraph?: number
          updated_at?: string
        }
        Relationships: []
      }
      prayer_blocks: {
        Row: {
          audio_key: string | null
          content: Json
          created_at: string
          id: string
          meta: Json
          mystery_id: string | null
          order_index: number
          prayer_id: string
          repeat_count: number
          section_id: string | null
          slug: string | null
          title: string | null
          type: string
          updated_at: string
        }
        Insert: {
          audio_key?: string | null
          content?: Json
          created_at?: string
          id?: string
          meta?: Json
          mystery_id?: string | null
          order_index?: number
          prayer_id: string
          repeat_count?: number
          section_id?: string | null
          slug?: string | null
          title?: string | null
          type: string
          updated_at?: string
        }
        Update: {
          audio_key?: string | null
          content?: Json
          created_at?: string
          id?: string
          meta?: Json
          mystery_id?: string | null
          order_index?: number
          prayer_id?: string
          repeat_count?: number
          section_id?: string | null
          slug?: string | null
          title?: string | null
          type?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "prayer_blocks_mystery_id_fkey"
            columns: ["mystery_id"]
            isOneToOne: false
            referencedRelation: "prayer_mysteries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "prayer_blocks_prayer_id_fkey"
            columns: ["prayer_id"]
            isOneToOne: false
            referencedRelation: "prayers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "prayer_blocks_section_id_fkey"
            columns: ["section_id"]
            isOneToOne: false
            referencedRelation: "prayer_sections"
            referencedColumns: ["id"]
          },
        ]
      }
      prayer_mysteries: {
        Row: {
          created_at: string
          fruit: string | null
          gospel_ref: string | null
          gospel_text: string | null
          id: string
          image_key: string | null
          meditation: string | null
          meta: Json
          order_index: number
          section_id: string
          slug: string
          subtitle: string | null
          title: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          fruit?: string | null
          gospel_ref?: string | null
          gospel_text?: string | null
          id?: string
          image_key?: string | null
          meditation?: string | null
          meta?: Json
          order_index?: number
          section_id: string
          slug: string
          subtitle?: string | null
          title: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          fruit?: string | null
          gospel_ref?: string | null
          gospel_text?: string | null
          id?: string
          image_key?: string | null
          meditation?: string | null
          meta?: Json
          order_index?: number
          section_id?: string
          slug?: string
          subtitle?: string | null
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "prayer_mysteries_section_id_fkey"
            columns: ["section_id"]
            isOneToOne: false
            referencedRelation: "prayer_sections"
            referencedColumns: ["id"]
          },
        ]
      }
      prayer_sections: {
        Row: {
          created_at: string
          id: string
          meta: Json
          order_index: number
          prayer_id: string
          slug: string
          subtitle: string | null
          title: string
          updated_at: string
          weekdays: number[]
        }
        Insert: {
          created_at?: string
          id?: string
          meta?: Json
          order_index?: number
          prayer_id: string
          slug: string
          subtitle?: string | null
          title: string
          updated_at?: string
          weekdays?: number[]
        }
        Update: {
          created_at?: string
          id?: string
          meta?: Json
          order_index?: number
          prayer_id?: string
          slug?: string
          subtitle?: string | null
          title?: string
          updated_at?: string
          weekdays?: number[]
        }
        Relationships: [
          {
            foreignKeyName: "prayer_sections_prayer_id_fkey"
            columns: ["prayer_id"]
            isOneToOne: false
            referencedRelation: "prayers"
            referencedColumns: ["id"]
          },
        ]
      }
      prayers: {
        Row: {
          category: Database["public"]["Enums"]["prayer_category"]
          content: string
          content_latin: string | null
          created_at: string
          engine_version: number
          estimated_seconds: number
          explanation: string | null
          id: string
          is_published: boolean
          kicker: string | null
          meditation: string | null
          order_index: number
          related_bible: string[]
          related_catechism: number[]
          related_glossary: string[]
          related_saints: string[]
          slug: string
          source_ref: string | null
          subtitle: string | null
          tags: string[]
          title: string
          updated_at: string
        }
        Insert: {
          category: Database["public"]["Enums"]["prayer_category"]
          content: string
          content_latin?: string | null
          created_at?: string
          engine_version?: number
          estimated_seconds?: number
          explanation?: string | null
          id?: string
          is_published?: boolean
          kicker?: string | null
          meditation?: string | null
          order_index?: number
          related_bible?: string[]
          related_catechism?: number[]
          related_glossary?: string[]
          related_saints?: string[]
          slug: string
          source_ref?: string | null
          subtitle?: string | null
          tags?: string[]
          title: string
          updated_at?: string
        }
        Update: {
          category?: Database["public"]["Enums"]["prayer_category"]
          content?: string
          content_latin?: string | null
          created_at?: string
          engine_version?: number
          estimated_seconds?: number
          explanation?: string | null
          id?: string
          is_published?: boolean
          kicker?: string | null
          meditation?: string | null
          order_index?: number
          related_bible?: string[]
          related_catechism?: number[]
          related_glossary?: string[]
          related_saints?: string[]
          slug?: string
          source_ref?: string | null
          subtitle?: string | null
          tags?: string[]
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      profiles: {
        Row: {
          avatar_url: string | null
          created_at: string
          email: string
          id: string
          is_premium: boolean
          name: string
          updated_at: string
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string
          email?: string
          id: string
          is_premium?: boolean
          name?: string
          updated_at?: string
        }
        Update: {
          avatar_url?: string | null
          created_at?: string
          email?: string
          id?: string
          is_premium?: boolean
          name?: string
          updated_at?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          created_at: string
          id: string
          role: Database["public"]["Enums"]["app_role"]
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          role: Database["public"]["Enums"]["app_role"]
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
      is_admin: { Args: never; Returns: boolean }
    }
    Enums: {
      app_role: "admin" | "moderator" | "user" | "editor" | "reviewer"
      bible_import_phase:
        | "A_pentateuco"
        | "B_historicos"
        | "C_sapienciais"
        | "D_profetas"
        | "E_novo_testamento"
      bible_phase_status:
        | "pending"
        | "importing"
        | "imported"
        | "certified"
        | "rejected"
      bible_translation_pipeline_stage:
        | "draft"
        | "importing"
        | "integrity_check"
        | "editorial_review"
        | "ice"
        | "certified"
        | "primary"
        | "archived"
      content_curation_status: "stub" | "partial" | "complete"
      editorial_status_enum:
        | "draft"
        | "doctrinal_review"
        | "editorial_review"
        | "ice_pending"
        | "published"
        | "archived"
      library_kind:
        | "saint_work"
        | "patristic"
        | "doctor"
        | "classic"
        | "magisterium"
      prayer_category:
        | "fundamentais"
        | "marianas"
        | "espirito_santo"
        | "santos"
        | "antes_depois"
        | "protecao"
        | "momentos_do_dia"
        | "eucaristica"
        | "confissao_defuntos"
      saint_content_status: "stub" | "partial" | "complete"
      saint_work_access_type:
        | "internal"
        | "official_external"
        | "public_domain"
        | "licensed"
      saint_work_category:
        | "patristica"
        | "escolastica"
        | "mistica"
        | "monastica"
        | "carmelita"
        | "franciscana"
        | "dominicana"
        | "doutor"
        | "espiritualidade"
        | "apologetica"
        | "liturgica"
        | "classic"
        | "magisterio"
      saint_work_ficha_completeness: "stub" | "minimal" | "complete"
      saint_work_reading_level: "beginner" | "intermediate" | "advanced"
      saint_work_status: "draft" | "in_review" | "published" | "archived"
      search_result_type:
        | "bible"
        | "catechism"
        | "saint"
        | "patristic"
        | "magisterium"
        | "prayer"
        | "journey"
        | "glossary"
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
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
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
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
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
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
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
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
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
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      app_role: ["admin", "moderator", "user", "editor", "reviewer"],
      bible_import_phase: [
        "A_pentateuco",
        "B_historicos",
        "C_sapienciais",
        "D_profetas",
        "E_novo_testamento",
      ],
      bible_phase_status: [
        "pending",
        "importing",
        "imported",
        "certified",
        "rejected",
      ],
      bible_translation_pipeline_stage: [
        "draft",
        "importing",
        "integrity_check",
        "editorial_review",
        "ice",
        "certified",
        "primary",
        "archived",
      ],
      content_curation_status: ["stub", "partial", "complete"],
      editorial_status_enum: [
        "draft",
        "doctrinal_review",
        "editorial_review",
        "ice_pending",
        "published",
        "archived",
      ],
      library_kind: [
        "saint_work",
        "patristic",
        "doctor",
        "classic",
        "magisterium",
      ],
      prayer_category: [
        "fundamentais",
        "marianas",
        "espirito_santo",
        "santos",
        "antes_depois",
        "protecao",
        "momentos_do_dia",
        "eucaristica",
        "confissao_defuntos",
      ],
      saint_content_status: ["stub", "partial", "complete"],
      saint_work_access_type: [
        "internal",
        "official_external",
        "public_domain",
        "licensed",
      ],
      saint_work_category: [
        "patristica",
        "escolastica",
        "mistica",
        "monastica",
        "carmelita",
        "franciscana",
        "dominicana",
        "doutor",
        "espiritualidade",
        "apologetica",
        "liturgica",
        "classic",
        "magisterio",
      ],
      saint_work_ficha_completeness: ["stub", "minimal", "complete"],
      saint_work_reading_level: ["beginner", "intermediate", "advanced"],
      saint_work_status: ["draft", "in_review", "published", "archived"],
      search_result_type: [
        "bible",
        "catechism",
        "saint",
        "patristic",
        "magisterium",
        "prayer",
        "journey",
        "glossary",
      ],
    },
  },
} as const
