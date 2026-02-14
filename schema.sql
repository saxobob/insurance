--
-- PostgreSQL database dump
--

\restrict ODrNbUgqH2Hqs8SzdV7dF5tx8ZB7qJbMAw156THZOz5ZYhAmBalzE6vND3G75d3

-- Dumped from database version 18.2
-- Dumped by pg_dump version 18.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid NOT NULL,
    user_id uuid,
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    action text NOT NULL,
    reason text,
    ip_address inet,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.audit_log OWNER TO postgres;

--
-- Name: binders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.binders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid NOT NULL,
    binder_name text NOT NULL,
    binder_holder text NOT NULL,
    api_endpoint text,
    supports_api_rating boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.binders OWNER TO postgres;

--
-- Name: bordereaux_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bordereaux_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bordereau_run_id uuid NOT NULL,
    policy_id uuid NOT NULL,
    policy_version_id uuid NOT NULL,
    included boolean DEFAULT true NOT NULL,
    validation_errors jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.bordereaux_items OWNER TO postgres;

--
-- Name: bordereaux_runs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bordereaux_runs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binder_id uuid NOT NULL,
    run_type text NOT NULL,
    period_start date,
    period_end date,
    file_name text,
    status text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.bordereaux_runs OWNER TO postgres;

--
-- Name: brokers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.brokers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    fca_number text,
    status text DEFAULT 'active'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.brokers OWNER TO postgres;

--
-- Name: claims; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.claims (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid NOT NULL,
    policy_id uuid NOT NULL,
    policy_version_id uuid,
    date_of_loss date NOT NULL,
    description text NOT NULL,
    estimated_loss numeric(12,2),
    police_reported boolean DEFAULT false NOT NULL,
    status text DEFAULT 'notified'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    handler_id uuid,
    handler_notes text
);


ALTER TABLE public.claims OWNER TO postgres;

--
-- Name: commission_clawbacks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commission_clawbacks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    policy_version_id uuid NOT NULL,
    original_commission numeric(12,2) NOT NULL,
    clawback_amount numeric(12,2) NOT NULL,
    clawback_date date NOT NULL,
    reason text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.commission_clawbacks OWNER TO postgres;

--
-- Name: commission_splits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commission_splits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    policy_financial_id uuid NOT NULL,
    payee_name text NOT NULL,
    payee_type text NOT NULL,
    rate numeric(5,2),
    amount numeric(12,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.commission_splits OWNER TO postgres;

--
-- Name: complaints; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.complaints (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid NOT NULL,
    customer_id uuid,
    policy_id uuid,
    received_at timestamp with time zone NOT NULL,
    channel text NOT NULL,
    summary text NOT NULL,
    acknowledged_at timestamp with time zone,
    resolved_at timestamp with time zone,
    outcome text,
    fos_referred boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    owner_id uuid,
    internal_notes text
);


ALTER TABLE public.complaints OWNER TO postgres;

--
-- Name: customer_timeline; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_timeline (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid NOT NULL,
    event_type text NOT NULL,
    event_date timestamp with time zone NOT NULL,
    description text NOT NULL,
    related_entity_type text,
    related_entity_id uuid,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.customer_timeline OWNER TO postgres;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid NOT NULL,
    customer_type text NOT NULL,
    full_name text NOT NULL,
    company_name text,
    company_number text,
    email text,
    phone text,
    address_json jsonb,
    gdpr_lawful_basis text NOT NULL,
    marketing_consent boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_commercial_has_company CHECK (((customer_type = 'retail'::text) OR ((customer_type = 'commercial'::text) AND (company_name IS NOT NULL)))),
    CONSTRAINT chk_customer_type CHECK ((customer_type = ANY (ARRAY['retail'::text, 'commercial'::text])))
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid NOT NULL,
    policy_version_id uuid,
    customer_id uuid,
    document_type text NOT NULL,
    file_name text NOT NULL,
    storage_key text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    version_number integer DEFAULT 1 NOT NULL,
    superseded_by uuid
);


ALTER TABLE public.documents OWNER TO postgres;

--
-- Name: email_templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid,
    template_name text NOT NULL,
    subject_template text NOT NULL,
    body_template text NOT NULL,
    template_type text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.email_templates OWNER TO postgres;

--
-- Name: emails; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.emails (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid NOT NULL,
    customer_id uuid,
    policy_id uuid,
    subject text NOT NULL,
    sent_to text NOT NULL,
    sent_at timestamp with time zone NOT NULL,
    body text
);


ALTER TABLE public.emails OWNER TO postgres;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid NOT NULL,
    policy_version_id uuid NOT NULL,
    invoice_number text NOT NULL,
    invoice_date date NOT NULL,
    due_date date NOT NULL,
    total_amount numeric(12,2) NOT NULL,
    status text DEFAULT 'outstanding'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- Name: ipid_acknowledgements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ipid_acknowledgements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    policy_version_id uuid NOT NULL,
    acknowledged_at timestamp with time zone NOT NULL,
    acknowledged_by text
);


ALTER TABLE public.ipid_acknowledgements OWNER TO postgres;

--
-- Name: ipid_templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ipid_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    template_content text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    approved_by uuid,
    approved_at timestamp with time zone,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ipid_templates OWNER TO postgres;

--
-- Name: kyc_checks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kyc_checks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid NOT NULL,
    check_date timestamp with time zone NOT NULL,
    check_type text NOT NULL,
    provider text,
    outcome text NOT NULL,
    evidence_stored boolean DEFAULT false NOT NULL,
    notes text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.kyc_checks OWNER TO postgres;

--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: policies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.policies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    product_id uuid NOT NULL,
    policy_number text NOT NULL,
    status text NOT NULL,
    inception_date date NOT NULL,
    expiry_date date NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_policy_status CHECK ((status = ANY (ARRAY['draft'::text, 'quoted'::text, 'bound'::text, 'issued'::text, 'in_force'::text, 'endorsement_pending'::text, 'endorsed'::text, 'cancelled'::text, 'lapsed'::text, 'expired'::text])))
);


ALTER TABLE public.policies OWNER TO postgres;

--
-- Name: policy_financials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.policy_financials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    policy_version_id uuid NOT NULL,
    gross_premium numeric(12,2) NOT NULL,
    broker_fee numeric(12,2) DEFAULT 0 NOT NULL,
    commission_rate numeric(5,2),
    commission_amount numeric(12,2),
    ipt_rate numeric(5,2),
    ipt_amount numeric(12,2),
    net_to_insurer numeric(12,2),
    currency text DEFAULT 'GBP'::text NOT NULL,
    ipt_rate_id uuid,
    CONSTRAINT chk_positive_premium CHECK ((gross_premium >= (0)::numeric))
);


ALTER TABLE public.policy_financials OWNER TO postgres;

--
-- Name: policy_risk_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.policy_risk_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    policy_version_id uuid NOT NULL,
    item_type text NOT NULL,
    item_data jsonb NOT NULL,
    sum_insured numeric(12,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.policy_risk_items OWNER TO postgres;

--
-- Name: policy_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.policy_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    policy_id uuid NOT NULL,
    version_number integer NOT NULL,
    transaction_type text NOT NULL,
    effective_date date NOT NULL,
    reason text,
    rating_payload jsonb,
    rating_response jsonb,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.policy_versions OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binder_id uuid NOT NULL,
    product_code text NOT NULL,
    name text NOT NULL,
    class_of_business text NOT NULL,
    retail_consumer boolean NOT NULL,
    ipid_required boolean NOT NULL,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: receipt_allocations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.receipt_allocations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    receipt_id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    amount numeric(12,2) NOT NULL
);


ALTER TABLE public.receipt_allocations OWNER TO postgres;

--
-- Name: receipts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.receipts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid NOT NULL,
    receipt_date date NOT NULL,
    amount numeric(12,2) NOT NULL,
    payment_method text NOT NULL,
    reference text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.receipts OWNER TO postgres;

--
-- Name: renewals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.renewals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    policy_id uuid NOT NULL,
    renewal_date date NOT NULL,
    quote_generated_at timestamp with time zone,
    quote_sent_at timestamp with time zone,
    quoted_premium numeric(12,2),
    status text NOT NULL,
    accepted_at timestamp with time zone,
    declined_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.renewals OWNER TO postgres;

--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permissions (
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL
);


ALTER TABLE public.role_permissions OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: tax_rates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_rates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid NOT NULL,
    tax_type text NOT NULL,
    class_of_business text NOT NULL,
    rate numeric(5,2) NOT NULL,
    effective_from date NOT NULL,
    effective_to date,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tax_rates OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    broker_id uuid NOT NULL,
    email text NOT NULL,
    full_name text NOT NULL,
    mfa_enabled boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    role_id uuid
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: binders binders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.binders
    ADD CONSTRAINT binders_pkey PRIMARY KEY (id);


--
-- Name: bordereaux_items bordereaux_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bordereaux_items
    ADD CONSTRAINT bordereaux_items_pkey PRIMARY KEY (id);


--
-- Name: bordereaux_runs bordereaux_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bordereaux_runs
    ADD CONSTRAINT bordereaux_runs_pkey PRIMARY KEY (id);


--
-- Name: brokers brokers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brokers
    ADD CONSTRAINT brokers_pkey PRIMARY KEY (id);


--
-- Name: claims claims_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.claims
    ADD CONSTRAINT claims_pkey PRIMARY KEY (id);


--
-- Name: commission_clawbacks commission_clawbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_clawbacks
    ADD CONSTRAINT commission_clawbacks_pkey PRIMARY KEY (id);


--
-- Name: commission_splits commission_splits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_splits
    ADD CONSTRAINT commission_splits_pkey PRIMARY KEY (id);


--
-- Name: complaints complaints_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_pkey PRIMARY KEY (id);


--
-- Name: customer_timeline customer_timeline_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_timeline
    ADD CONSTRAINT customer_timeline_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: email_templates email_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_templates
    ADD CONSTRAINT email_templates_pkey PRIMARY KEY (id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: ipid_acknowledgements ipid_acknowledgements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ipid_acknowledgements
    ADD CONSTRAINT ipid_acknowledgements_pkey PRIMARY KEY (id);


--
-- Name: ipid_templates ipid_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ipid_templates
    ADD CONSTRAINT ipid_templates_pkey PRIMARY KEY (id);


--
-- Name: kyc_checks kyc_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_checks
    ADD CONSTRAINT kyc_checks_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_code_key UNIQUE (code);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: policies policies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policies
    ADD CONSTRAINT policies_pkey PRIMARY KEY (id);


--
-- Name: policy_financials policy_financials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policy_financials
    ADD CONSTRAINT policy_financials_pkey PRIMARY KEY (id);


--
-- Name: policy_risk_items policy_risk_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policy_risk_items
    ADD CONSTRAINT policy_risk_items_pkey PRIMARY KEY (id);


--
-- Name: policy_versions policy_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policy_versions
    ADD CONSTRAINT policy_versions_pkey PRIMARY KEY (id);


--
-- Name: policy_versions policy_versions_policy_id_version_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policy_versions
    ADD CONSTRAINT policy_versions_policy_id_version_number_key UNIQUE (policy_id, version_number);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: receipt_allocations receipt_allocations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipt_allocations
    ADD CONSTRAINT receipt_allocations_pkey PRIMARY KEY (id);


--
-- Name: receipts receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_pkey PRIMARY KEY (id);


--
-- Name: renewals renewals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renewals
    ADD CONSTRAINT renewals_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: tax_rates tax_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rates
    ADD CONSTRAINT tax_rates_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_audit_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_created ON public.audit_log USING btree (created_at DESC);


--
-- Name: idx_audit_entity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_entity ON public.audit_log USING btree (entity_type, entity_id);


--
-- Name: idx_claims_policy; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_claims_policy ON public.claims USING btree (policy_id);


--
-- Name: idx_claims_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_claims_status ON public.claims USING btree (broker_id, status);


--
-- Name: idx_complaints_broker; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_complaints_broker ON public.complaints USING btree (broker_id);


--
-- Name: idx_complaints_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_complaints_status ON public.complaints USING btree (broker_id, resolved_at) WHERE (resolved_at IS NULL);


--
-- Name: idx_customers_broker; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customers_broker ON public.customers USING btree (broker_id, customer_type);


--
-- Name: idx_emails_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_emails_customer ON public.emails USING btree (customer_id);


--
-- Name: idx_policies_broker; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_policies_broker ON public.policies USING btree (broker_id);


--
-- Name: idx_policies_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_policies_customer ON public.policies USING btree (customer_id);


--
-- Name: idx_policies_expiry; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_policies_expiry ON public.policies USING btree (expiry_date) WHERE (status = ANY (ARRAY['in_force'::text, 'issued'::text]));


--
-- Name: idx_policies_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_policies_status ON public.policies USING btree (broker_id, status);


--
-- Name: idx_policy_financials_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_policy_financials_version ON public.policy_financials USING btree (policy_version_id);


--
-- Name: idx_policy_versions_policy; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_policy_versions_policy ON public.policy_versions USING btree (policy_id);


--
-- Name: idx_timeline_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timeline_customer ON public.customer_timeline USING btree (customer_id, event_date DESC);


--
-- Name: audit_log audit_log_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: audit_log audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: binders binders_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.binders
    ADD CONSTRAINT binders_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: bordereaux_items bordereaux_items_bordereau_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bordereaux_items
    ADD CONSTRAINT bordereaux_items_bordereau_run_id_fkey FOREIGN KEY (bordereau_run_id) REFERENCES public.bordereaux_runs(id);


--
-- Name: bordereaux_items bordereaux_items_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bordereaux_items
    ADD CONSTRAINT bordereaux_items_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.policies(id);


--
-- Name: bordereaux_items bordereaux_items_policy_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bordereaux_items
    ADD CONSTRAINT bordereaux_items_policy_version_id_fkey FOREIGN KEY (policy_version_id) REFERENCES public.policy_versions(id);


--
-- Name: bordereaux_runs bordereaux_runs_binder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bordereaux_runs
    ADD CONSTRAINT bordereaux_runs_binder_id_fkey FOREIGN KEY (binder_id) REFERENCES public.binders(id);


--
-- Name: claims claims_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.claims
    ADD CONSTRAINT claims_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: claims claims_handler_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.claims
    ADD CONSTRAINT claims_handler_id_fkey FOREIGN KEY (handler_id) REFERENCES public.users(id);


--
-- Name: claims claims_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.claims
    ADD CONSTRAINT claims_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.policies(id);


--
-- Name: claims claims_policy_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.claims
    ADD CONSTRAINT claims_policy_version_id_fkey FOREIGN KEY (policy_version_id) REFERENCES public.policy_versions(id);


--
-- Name: commission_clawbacks commission_clawbacks_policy_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_clawbacks
    ADD CONSTRAINT commission_clawbacks_policy_version_id_fkey FOREIGN KEY (policy_version_id) REFERENCES public.policy_versions(id);


--
-- Name: commission_splits commission_splits_policy_financial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_splits
    ADD CONSTRAINT commission_splits_policy_financial_id_fkey FOREIGN KEY (policy_financial_id) REFERENCES public.policy_financials(id);


--
-- Name: complaints complaints_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: complaints complaints_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: complaints complaints_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: complaints complaints_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.policies(id);


--
-- Name: customer_timeline customer_timeline_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_timeline
    ADD CONSTRAINT customer_timeline_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: customer_timeline customer_timeline_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_timeline
    ADD CONSTRAINT customer_timeline_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: customers customers_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: documents documents_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: documents documents_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: documents documents_policy_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_policy_version_id_fkey FOREIGN KEY (policy_version_id) REFERENCES public.policy_versions(id);


--
-- Name: documents documents_superseded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_superseded_by_fkey FOREIGN KEY (superseded_by) REFERENCES public.documents(id);


--
-- Name: email_templates email_templates_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_templates
    ADD CONSTRAINT email_templates_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: emails emails_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: emails emails_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: emails emails_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.policies(id);


--
-- Name: invoices invoices_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: invoices invoices_policy_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_policy_version_id_fkey FOREIGN KEY (policy_version_id) REFERENCES public.policy_versions(id);


--
-- Name: ipid_acknowledgements ipid_acknowledgements_policy_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ipid_acknowledgements
    ADD CONSTRAINT ipid_acknowledgements_policy_version_id_fkey FOREIGN KEY (policy_version_id) REFERENCES public.policy_versions(id);


--
-- Name: ipid_templates ipid_templates_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ipid_templates
    ADD CONSTRAINT ipid_templates_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: ipid_templates ipid_templates_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ipid_templates
    ADD CONSTRAINT ipid_templates_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: kyc_checks kyc_checks_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_checks
    ADD CONSTRAINT kyc_checks_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: kyc_checks kyc_checks_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_checks
    ADD CONSTRAINT kyc_checks_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: policies policies_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policies
    ADD CONSTRAINT policies_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: policies policies_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policies
    ADD CONSTRAINT policies_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: policies policies_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policies
    ADD CONSTRAINT policies_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: policy_financials policy_financials_ipt_rate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policy_financials
    ADD CONSTRAINT policy_financials_ipt_rate_id_fkey FOREIGN KEY (ipt_rate_id) REFERENCES public.tax_rates(id);


--
-- Name: policy_financials policy_financials_policy_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policy_financials
    ADD CONSTRAINT policy_financials_policy_version_id_fkey FOREIGN KEY (policy_version_id) REFERENCES public.policy_versions(id);


--
-- Name: policy_risk_items policy_risk_items_policy_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policy_risk_items
    ADD CONSTRAINT policy_risk_items_policy_version_id_fkey FOREIGN KEY (policy_version_id) REFERENCES public.policy_versions(id);


--
-- Name: policy_versions policy_versions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policy_versions
    ADD CONSTRAINT policy_versions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: policy_versions policy_versions_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policy_versions
    ADD CONSTRAINT policy_versions_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.policies(id);


--
-- Name: products products_binder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_binder_id_fkey FOREIGN KEY (binder_id) REFERENCES public.binders(id);


--
-- Name: receipt_allocations receipt_allocations_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipt_allocations
    ADD CONSTRAINT receipt_allocations_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id);


--
-- Name: receipt_allocations receipt_allocations_receipt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipt_allocations
    ADD CONSTRAINT receipt_allocations_receipt_id_fkey FOREIGN KEY (receipt_id) REFERENCES public.receipts(id);


--
-- Name: receipts receipts_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: renewals renewals_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renewals
    ADD CONSTRAINT renewals_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.policies(id);


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id);


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: roles roles_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: tax_rates tax_rates_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rates
    ADD CONSTRAINT tax_rates_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: users users_broker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_broker_id_fkey FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- PostgreSQL database dump complete
--

\unrestrict ODrNbUgqH2Hqs8SzdV7dF5tx8ZB7qJbMAw156THZOz5ZYhAmBalzE6vND3G75d3

