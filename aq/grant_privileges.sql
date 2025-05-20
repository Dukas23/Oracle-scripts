--GRANT EXECUTE ON aq_admin.orders_message_type TO aq_user;
GRANT EXECUTE ON orders_message_type TO aq_user;
GRANT EXECUTE ON fn_Dollars_to_Euro TO aq_user;
GRANT EXECUTE ON fn_Dollars_to_Pesos TO aq_user;

BEGIN
 DBMS_AQADM.GRANT_QUEUE_PRIVILEGE(
   privilege => 'ALL',
   queue_name => 'aq_admin.orders_msg_queue',
   grantee => 'aq_user',
   grant_option => FALSE);
END;
/
