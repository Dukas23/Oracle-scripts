DECLARE
  enqueue_options    dbms_aq.enqueue_options_t;
  message_properties dbms_aq.message_properties_t;
  message_handle     RAW(16);
  message            aq_admin.orders_message_type;
  message_id NUMBER;
BEGIN
  message := aq_admin.orders_message_type (1,       -- order id
                                           '325',   -- customer_id
                                           '49',    -- product_code
                                           'Details: Digital Camera. Brand: ABC. Model: XYX' ,
                                           50.2,    -- price
                                           'EUROPE' -- Region
                                          );
  -- default for enqueue options VISIBILITY is 
  -- ON_COMMIT. message has no delay and no -- expiration

  message_properties.CORRELATION    := message.order_id;
  
  DBMS_AQ.ENQUEUE (queue_name =>         'aq_admin.orders_msg_queue', 
                   enqueue_options =>    enqueue_options,
                   message_properties => message_properties,
                   payload =>            message,
                   msgid =>              message_handle);
  COMMIT;
END;
/

DECLARE
  enqueue_options    dbms_aq.enqueue_options_t;
  message_properties dbms_aq.message_properties_t;
  message_handle     RAW(16);
  message            aq_admin.orders_message_type;
  message_id NUMBER;
BEGIN
  message := aq_admin.orders_message_type (1,       -- order id
                                           '325',   -- customer_id
                                           '49',    -- product_code
                                           'Details: Digital Camera. Brand: ABC. Model: XYX' ,
                                           50.2,    -- price
                                           'USA' -- Region
                                          );
  -- default for enqueue options VISIBILITY is 
  -- ON_COMMIT. message has no delay and no -- expiration

  message_properties.CORRELATION    := message.order_id;
  
  DBMS_AQ.ENQUEUE (queue_name =>         'aq_admin.orders_msg_queue', 
                   enqueue_options =>    enqueue_options,
                   message_properties => message_properties,
                   payload =>            message,
                   msgid =>              message_handle);
  COMMIT;
END;
/



DECLARE
  enqueue_options    dbms_aq.enqueue_options_t;
  message_properties dbms_aq.message_properties_t;
  message_handle     RAW(16);
  message            aq_admin.orders_message_type;
  message_id NUMBER;
BEGIN
  message := aq_admin.orders_message_type (1,       -- order id
                                           '325',   -- customer_id
                                           '49',    -- product_code
                                           'Details: Digital Camera. Brand: ABC. Model: XYX' ,
                                           50.2,    -- price
                                           'MEXICO' -- Region
                                          );
  -- default for enqueue options VISIBILITY is 
  -- ON_COMMIT. message has no delay and no -- expiration

  message_properties.CORRELATION    := message.order_id;
  
  DBMS_AQ.ENQUEUE (queue_name =>         'aq_admin.orders_msg_queue', 
                   enqueue_options =>    enqueue_options,
                   message_properties => message_properties,
                   payload =>            message,
                   msgid =>              message_handle);
  COMMIT;
END;
/