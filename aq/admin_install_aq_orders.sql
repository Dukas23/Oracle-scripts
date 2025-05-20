--
-- install_aq_orders.sql
--
-- Execution:
-- Connected as "SYS" (user administrator)
--

--
-- Creates the admin and user for out queue
--
@@create_aq_admin.sql
@@create_aq_user.sql

--
-- Change to aq_admin schema
--
ALTER SESSION SET CURRENT_SCHEMA=AQ_ADMIN;
CONNECT aq_admin/aq_admin;

--
-- Create data structures
--
@@create_data_structures.sql

--
-- Create suscribers
--
@@create_suscribers.sql

--
-- Grant privileges
--
@@grant_privileges.sql

--
-- Back to gogomez schema
--
EXIT;
ALTER SESSION SET CURRENT_SCHEMA=SYS;
