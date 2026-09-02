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
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
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
