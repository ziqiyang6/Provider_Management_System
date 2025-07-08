CREATE TYPE "provider_type" AS ENUM (
  'individual',
  'organization'
);

CREATE TYPE "enrollment_status" AS ENUM (
  'draft',
  'submitted',
  'under_review',
  'pending_information',
  'approved',
  'rejected',
  'terminated',
  'suspended'
);

CREATE TYPE "credential_type" AS ENUM (
  'medical_license',
  'board_certification',
  'dea_registration',
  'cds_registration',
  'education_degree',
  'residency_training',
  'fellowship_training',
  'continuing_education',
  'malpractice_insurance',
  'hospital_privileges',
  'other'
);

CREATE TYPE "credential_status" AS ENUM (
  'pending_verification',
  'verified',
  'expired',
  'revoked',
  'suspended',
  'rejected'
);

CREATE TYPE "document_type" AS ENUM (
  'license_certificate',
  'board_certification',
  'education_diploma',
  'training_certificate',
  'insurance_certificate',
  'cv_resume',
  'application_form',
  'supporting_document',
  'correspondence',
  'other'
);

CREATE TYPE "upload_status" AS ENUM (
  'pending',
  'uploading',
  'completed',
  'failed',
  'processing'
);

CREATE TYPE "virus_scan_status" AS ENUM (
  'pending',
  'scanning',
  'clean',
  'infected',
  'failed'
);

CREATE TYPE "access_level" AS ENUM (
  'provider_only',
  'reviewer_access',
  'admin_access',
  'public'
);

CREATE TYPE "application_type" AS ENUM (
  'initial_enrollment',
  'revalidation',
  'change_request',
  'reinstatement',
  'voluntary_termination'
);

CREATE TYPE "application_status" AS ENUM (
  'draft',
  'submitted',
  'under_review',
  'pending_information',
  'approved',
  'rejected',
  'withdrawn',
  'expired'
);

CREATE TYPE "priority_level" AS ENUM (
  'low',
  'normal',
  'high',
  'urgent'
);

CREATE TYPE "communication_type" AS ENUM (
  'message',
  'notification',
  'request_for_information',
  'status_update',
  'reminder',
  'alert'
);

CREATE TYPE "delivery_status" AS ENUM (
  'pending',
  'delivered',
  'failed',
  'bounced'
);

CREATE TYPE "audit_action" AS ENUM (
  'create',
  'read',
  'update',
  'delete',
  'login',
  'logout',
  'password_change',
  'permission_change',
  'document_upload',
  'document_download',
  'status_change',
  'assignment_change'
);

CREATE TABLE "users"
(
    "id"                     uuid PRIMARY KEY             DEFAULT (gen_random_uuid()),
    "email"                  varchar(255) UNIQUE NOT NULL,
    "password_hash"          varchar(255)        NOT NULL,
    "first_name"             varchar(100)        NOT NULL,
    "last_name"              varchar(100)        NOT NULL,
    "role_id"                   uuid           NOT NULL ,
    "is_active"              boolean                      DEFAULT true,
    "email_verified"         boolean                      DEFAULT false,
    "last_login"             timestamptz,
    "password_reset_token"   varchar(255),
    "password_reset_expires" timestamptz,
    "created_at"             timestamptz                  DEFAULT (CURRENT_TIMESTAMP),
    "updated_at"             timestamptz                  DEFAULT (CURRENT_TIMESTAMP),
    "created_by"             uuid,
    "updated_by"             uuid
);

CREATE TABLE "addresses"
(
    "id"            uuid PRIMARY KEY DEFAULT (gen_random_uuid()),
    "npi"           varchar(10) NOT NULL,
    "type"          varchar     not null,
    "address_line1" varchar(255),
    "address_line2" varchar(255),
    "city"          varchar(100),
    "state"         varchar(2),
    "zip"           varchar(10),
    "phone"         varchar(20),
    "created_at"    timestamptz      DEFAULT (CURRENT_TIMESTAMP),
    "updated_at"    timestamptz      DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "providers"
(
    "id"                     uuid PRIMARY KEY  DEFAULT (gen_random_uuid()),
    "user_id"                uuid,
    "npi"                    varchar(10) UNIQUE NOT NULL,
    "nppes_data"             jsonb,
    "organization_name"      varchar(255),
    "individual_first_name"  varchar(100),
    "individual_last_name"   varchar(100),
    "individual_middle_name" varchar(100),
    "provider_type"          provider_type      NOT NULL,
    "enrollment_status"      enrollment_status DEFAULT 'draft',
    "medicaid_provider_id"   varchar(50),
    "effective_date"         date,
    "termination_date"       date,
    "business_fax"           varchar(20),
    "contact_email"          varchar(255),
    "website_url"            varchar(255),
    "nppes_last_sync"        timestamptz,
    "created_at"             timestamptz       DEFAULT (CURRENT_TIMESTAMP),
    "updated_at"             timestamptz       DEFAULT (CURRENT_TIMESTAMP),
    "created_by"             uuid,
    "updated_by"             uuid
);

CREATE TABLE "credentials"
(
    "id"                  uuid PRIMARY KEY  DEFAULT (gen_random_uuid()),
    "provider_id"         uuid            NOT NULL,
    "credential_type"     credential_type NOT NULL,
    "credential_number"   varchar(100),
    "issuing_authority"   varchar(255)    NOT NULL,
    "issue_date"          date,
    "expiration_date"     date,
    "status"              credential_status DEFAULT 'pending_verification',
    "verification_date"   timestamptz,
    "verification_method" varchar(100),
    "verification_notes"  text,
    "is_primary"          boolean           DEFAULT false,
    "specialty_codes"     text[],
    "scope_of_practice"   text,
    "restrictions"        text,
    "created_at"          timestamptz       DEFAULT (CURRENT_TIMESTAMP),
    "updated_at"          timestamptz       DEFAULT (CURRENT_TIMESTAMP),
    "created_by"          uuid,
    "updated_by"          uuid
);

CREATE TABLE "documents"
(
    "id"                  uuid PRIMARY KEY  DEFAULT (gen_random_uuid()),
    "provider_id"         uuid          NOT NULL,
    "credential_id"       uuid,
    "document_type"       document_type NOT NULL,
    "file_name"           varchar(255)  NOT NULL,
    "file_path"           varchar(500)  NOT NULL,
    "file_size"           bigint        NOT NULL,
    "mime_type"           varchar(100)  NOT NULL,
    "file_hash"           varchar(64)   NOT NULL,
    "upload_status"       upload_status     DEFAULT 'pending',
    "virus_scan_status"   virus_scan_status DEFAULT 'pending',
    "virus_scan_date"     timestamptz,
    "document_date"       date,
    "expiration_date"     date,
    "version_number"      integer           DEFAULT 1,
    "is_current_version"  boolean           DEFAULT true,
    "previous_version_id" uuid,
    "tags"                text[],
    "description"         text,
    "access_level"        access_level      DEFAULT 'provider_only',
    "created_at"          timestamptz       DEFAULT (CURRENT_TIMESTAMP),
    "updated_at"          timestamptz       DEFAULT (CURRENT_TIMESTAMP),
    "created_by"          uuid,
    "updated_by"          uuid
);

CREATE TABLE "applications"
(
    "id"                     uuid PRIMARY KEY   DEFAULT (gen_random_uuid()),
    "provider_id"            uuid             NOT NULL,
    "application_type"       application_type NOT NULL,
    "status"                 application_status DEFAULT 'draft',
    "submitted_date"         timestamptz,
    "review_start_date"      timestamptz,
    "review_completion_date" timestamptz,
    "assigned_reviewer_id"   uuid,
    "priority"               priority_level     DEFAULT 'normal',
    "due_date"               date,
    "completion_percentage"  integer            DEFAULT 0,
    "checklist_items"        jsonb,
    "review_notes"           text,
    "decision_rationale"     text,
    "appeal_deadline"        date,
    "created_at"             timestamptz        DEFAULT (CURRENT_TIMESTAMP),
    "updated_at"             timestamptz        DEFAULT (CURRENT_TIMESTAMP),
    "created_by"             uuid,
    "updated_by"             uuid
);

CREATE TABLE "communications"
(
    "id"                      uuid PRIMARY KEY DEFAULT (gen_random_uuid()),
    "provider_id"             uuid               NOT NULL,
    "application_id"          uuid,
    "sender_id"               uuid               NOT NULL,
    "recipient_id"            uuid,
    "communication_type"      communication_type NOT NULL,
    "subject"                 varchar(255)       NOT NULL,
    "message"                 text               NOT NULL,
    "is_read"                 boolean          DEFAULT false,
    "read_date"               timestamptz,
    "priority"                priority_level   DEFAULT 'normal',
    "requires_response"       boolean          DEFAULT false,
    "response_due_date"       timestamptz,
    "parent_communication_id" uuid,
    "thread_id"               uuid,
    "attachments"             uuid[],
    "delivery_status"         delivery_status  DEFAULT 'pending',
    "delivery_date"           timestamptz,
    "created_at"              timestamptz      DEFAULT (CURRENT_TIMESTAMP),
    "updated_at"              timestamptz      DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "audit_logs"
(
    "id"            uuid PRIMARY KEY DEFAULT (gen_random_uuid()),
    "user_id"       uuid,
    "action"        audit_action NOT NULL,
    "entity_type"   varchar(50)  NOT NULL,
    "entity_id"     uuid         NOT NULL,
    "old_values"    jsonb,
    "new_values"    jsonb,
    "ip_address"    inet,
    "user_agent"    text,
    "session_id"    varchar(255),
    "timestamp"     timestamptz      DEFAULT (CURRENT_TIMESTAMP),
    "success"       boolean          DEFAULT true,
    "error_message" text
);

CREATE TABLE "taxonomy_codes"
(
    "id"                uuid PRIMARY KEY DEFAULT (gen_random_uuid()),
    "code"              varchar(20) UNIQUE NOT NULL,
    "type"              varchar(50)        NOT NULL,
    "classification"    varchar(255)       NOT NULL,
    "specialization"    varchar(255),
    "definition"        text,
    "notes"             text,
    "effective_date"    date,
    "deactivation_date" date,
    "created_at"        timestamptz      DEFAULT (CURRENT_TIMESTAMP),
    "updated_at"        timestamptz      DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "taxonomy_npi_relationship"
(
    "npi"  varchar(10) NOT NULL,
    "code" varchar(20) NOT NULL,
    PRIMARY KEY ("npi", "code")
);

CREATE TABLE "system_settings"
(
    "id"            uuid PRIMARY KEY DEFAULT (gen_random_uuid()),
    "setting_key"   varchar(100) UNIQUE NOT NULL,
    "setting_value" text                NOT NULL,
    "setting_type"  varchar(50)         NOT NULL,
    "description"   text,
    "is_encrypted"  boolean          DEFAULT false,
    "created_at"    timestamptz      DEFAULT (CURRENT_TIMESTAMP),
    "updated_at"    timestamptz      DEFAULT (CURRENT_TIMESTAMP),
    "created_by"    uuid,
    "updated_by"    uuid
);

CREATE TABLE "notification_preferences"
(
    "id"                   uuid PRIMARY KEY DEFAULT (gen_random_uuid()),
    "user_id"              uuid NOT NULL,
    "email_notifications"  boolean          DEFAULT true,
    "sms_notifications"    boolean          DEFAULT false,
    "in_app_notifications" boolean          DEFAULT true,
    "notification_types"   jsonb            DEFAULT '{}',
    "created_at"           timestamptz      DEFAULT (CURRENT_TIMESTAMP),
    "updated_at"           timestamptz      DEFAULT (CURRENT_TIMESTAMP)
);

COMMENT
ON TABLE "users" IS 'System users including providers, reviewers, and administrators';

COMMENT
ON TABLE "providers" IS 'Healthcare provider profiles and enrollment information';

COMMENT
ON TABLE "credentials" IS 'Professional credentials and certifications';

COMMENT
ON TABLE "documents" IS 'Document storage metadata and version control';

COMMENT
ON TABLE "applications" IS 'Provider enrollment and revalidation applications';

COMMENT
ON TABLE "communications" IS 'Messages and notifications between users';

COMMENT
ON TABLE "audit_logs" IS 'Comprehensive audit trail for all system activities';

COMMENT
ON TABLE "taxonomy_codes" IS 'Healthcare provider taxonomy reference data';

COMMENT
ON TABLE "system_settings" IS 'Application configuration settings';

COMMENT
ON TABLE "notification_preferences" IS 'User notification preferences';

ALTER TABLE "users"
    ADD FOREIGN KEY ("created_by") REFERENCES "users" ("id");

ALTER TABLE "users"
    ADD FOREIGN KEY ("updated_by") REFERENCES "users" ("id");

ALTER TABLE "providers"
    ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE;

ALTER TABLE "providers"
    ADD FOREIGN KEY ("created_by") REFERENCES "users" ("id");

ALTER TABLE "providers"
    ADD FOREIGN KEY ("updated_by") REFERENCES "users" ("id");

ALTER TABLE "addresses"
    ADD FOREIGN KEY ("npi") REFERENCES "providers" ("npi") ON DELETE CASCADE;

ALTER TABLE "taxonomy_npi_relationship"
    ADD FOREIGN KEY ("npi") REFERENCES "providers" ("npi") ON DELETE CASCADE;

ALTER TABLE "taxonomy_npi_relationship"
    ADD FOREIGN KEY ("code") REFERENCES "taxonomy_codes" ("code") ON DELETE CASCADE;

ALTER TABLE "credentials"
    ADD FOREIGN KEY ("provider_id") REFERENCES "providers" ("id") ON DELETE CASCADE;

ALTER TABLE "credentials"
    ADD FOREIGN KEY ("created_by") REFERENCES "users" ("id");

ALTER TABLE "credentials"
    ADD FOREIGN KEY ("updated_by") REFERENCES "users" ("id");

ALTER TABLE "documents"
    ADD FOREIGN KEY ("provider_id") REFERENCES "providers" ("id") ON DELETE CASCADE;

ALTER TABLE "documents"
    ADD FOREIGN KEY ("credential_id") REFERENCES "credentials" ("id") ON DELETE SET NULL;

ALTER TABLE "documents"
    ADD FOREIGN KEY ("previous_version_id") REFERENCES "documents" ("id");

ALTER TABLE "documents"
    ADD FOREIGN KEY ("created_by") REFERENCES "users" ("id");

ALTER TABLE "documents"
    ADD FOREIGN KEY ("updated_by") REFERENCES "users" ("id");

ALTER TABLE "applications"
    ADD FOREIGN KEY ("provider_id") REFERENCES "providers" ("id") ON DELETE CASCADE;

ALTER TABLE "applications"
    ADD FOREIGN KEY ("assigned_reviewer_id") REFERENCES "users" ("id");

ALTER TABLE "applications"
    ADD FOREIGN KEY ("created_by") REFERENCES "users" ("id");

ALTER TABLE "applications"
    ADD FOREIGN KEY ("updated_by") REFERENCES "users" ("id");

ALTER TABLE "communications"
    ADD FOREIGN KEY ("provider_id") REFERENCES "providers" ("id") ON DELETE CASCADE;

ALTER TABLE "communications"
    ADD FOREIGN KEY ("application_id") REFERENCES "applications" ("id") ON DELETE SET NULL;

ALTER TABLE "communications"
    ADD FOREIGN KEY ("sender_id") REFERENCES "users" ("id");

ALTER TABLE "communications"
    ADD FOREIGN KEY ("recipient_id") REFERENCES "users" ("id");

ALTER TABLE "communications"
    ADD FOREIGN KEY ("parent_communication_id") REFERENCES "communications" ("id");

ALTER TABLE "audit_logs"
    ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "system_settings"
    ADD FOREIGN KEY ("created_by") REFERENCES "users" ("id");

ALTER TABLE "system_settings"
    ADD FOREIGN KEY ("updated_by") REFERENCES "users" ("id");

ALTER TABLE "notification_preferences"
    ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE;

--ALTER TABLE "addresses"
--    ADD FOREIGN KEY ("business_address_line2") REFERENCES "addresses" ("business_address_line1");

-- Drop the existing enum type (if you want to remove it completely)
-- DROP TYPE "user_role";

-- Create permissions table
CREATE TABLE "permissions" (
                               "id" uuid PRIMARY KEY DEFAULT (gen_random_uuid()),
                               "name" varchar(100) UNIQUE NOT NULL,
                               "description" text,
                               "resource" varchar(100) NOT NULL, -- e.g., 'users', 'providers', 'applications'
                               "action" varchar(50) NOT NULL,    -- e.g., 'create', 'read', 'update', 'delete'
                               "created_at" timestamptz DEFAULT (CURRENT_TIMESTAMP),
                               "updated_at" timestamptz DEFAULT (CURRENT_TIMESTAMP)
);

-- Create roles table
CREATE TABLE "roles" (
                         "id" uuid PRIMARY KEY DEFAULT (gen_random_uuid()),
                         "name" varchar(100) UNIQUE NOT NULL,
                         "description" text,
                         "is_active" boolean DEFAULT true,
                         "created_at" timestamptz DEFAULT (CURRENT_TIMESTAMP),
                         "updated_at" timestamptz DEFAULT (CURRENT_TIMESTAMP),
                         "created_by" uuid,
                         "updated_by" uuid
);

-- Create role-permission relationship table
CREATE TABLE "role_permissions" (
                                    "role_id" uuid NOT NULL,
                                    "permission_id" uuid NOT NULL,
                                    "created_at" timestamptz DEFAULT (CURRENT_TIMESTAMP),
                                    "created_by" uuid,
                                    PRIMARY KEY ("role_id", "permission_id"),
                                    FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE CASCADE,
                                    FOREIGN KEY ("permission_id") REFERENCES "permissions"("id") ON DELETE CASCADE
);

-- Update users table to reference roles

ALTER TABLE "users" ADD FOREIGN KEY ("role_id") REFERENCES "roles"("id");

-- Add foreign key constraints for created_by/updated_by if needed
ALTER TABLE "users" ADD FOREIGN KEY ("created_by") REFERENCES "users"("id");
ALTER TABLE "users" ADD FOREIGN KEY ("updated_by") REFERENCES "users"("id");
ALTER TABLE "roles" ADD FOREIGN KEY ("created_by") REFERENCES "users"("id");
ALTER TABLE "roles" ADD FOREIGN KEY ("updated_by") REFERENCES "users"("id");

-- Insert default roles
INSERT INTO "roles" ("name", "description") VALUES
                                                ('provider', 'Healthcare provider with basic access'),
                                                ('state_reviewer', 'State reviewer with approval permissions'),
                                                ('administrator', 'System administrator with elevated access'),
                                                ('super_admin', 'Super administrator with full system access');

-- Insert sample permissions
INSERT INTO "permissions" ("name", "description", "resource", "action") VALUES
                                                                            ('users.create', 'Create new users', 'users', 'create'),
                                                                            ('users.read', 'View user information', 'users', 'read'),
                                                                            ('users.update', 'Update user information', 'users', 'update'),
                                                                            ('users.delete', 'Delete users', 'users', 'delete'),
                                                                            ('providers.create', 'Create provider profiles', 'providers', 'create'),
                                                                            ('providers.read', 'View provider profiles', 'providers', 'read'),
                                                                            ('providers.update', 'Update provider profiles', 'providers', 'update'),
                                                                            ('providers.delete', 'Delete provider profiles', 'providers', 'delete'),
                                                                            ('applications.create', 'Create applications', 'applications', 'create'),
                                                                            ('applications.read', 'View applications', 'applications', 'read'),
                                                                            ('applications.update', 'Update applications', 'applications', 'update'),
                                                                            ('applications.delete', 'Delete applications', 'applications', 'delete'),
                                                                            ('applications.approve', 'Approve applications', 'applications', 'approve'),
                                                                            ('applications.reject', 'Reject applications', 'applications', 'reject'),
                                                                            ('system.admin', 'System administration access', 'system', 'admin');

-- Sample role-permission assignments
-- Provider permissions
-- INSERT INTO "role_permissions" ("role_id", "permission_id")
-- SELECT r.id, p.id
-- FROM "roles" r, "permissions" p
-- WHERE r.name = 'provider'
--   AND p.name IN ('providers.read', 'providers.update', 'applications.create', 'applications.read');
--
-- -- State reviewer permissions
-- INSERT INTO "role_permissions" ("role_id", "permission_id")
-- SELECT r.id, p.id
-- FROM "roles" r, "permissions" p
-- WHERE r.name = 'state_reviewer'
--   AND p.name IN ('providers.read', 'applications.read', 'applications.approve', 'applications.reject');
--
-- -- Administrator permissions
-- INSERT INTO "role_permissions" ("role_id", "permission_id")
-- SELECT r.id, p.id
-- FROM "roles" r, "permissions" p
-- WHERE r.name = 'administrator'
--   AND p.name IN ('users.create', 'users.read', 'users.update', 'providers.create', 'providers.read', 'providers.update', 'applications.create', 'applications.read', 'applications.update', 'applications.approve', 'applications.reject');
--
-- -- Super admin permissions (all permissions)
-- INSERT INTO "role_permissions" ("role_id", "permission_id")
-- SELECT r.id, p.id
-- FROM "roles" r, "permissions" p
-- WHERE r.name = 'super_admin';