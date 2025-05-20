CREATE TYPE orders_message_type AS OBJECT
(
    order_id NUMBER(15),
    Product_code VARCHAR2(10),
    Customer_id VARCHAR2(10),
    order_details VARCHAR2(4000),
    price NUMBER(4,2),
    region_code VARCHAR2(100)
);
/

BEGIN
 DBMS_AQADM.CREATE_QUEUE_TABLE (queue_table =>        'orders_msg_qt',
                                queue_payload_type => 'orders_message_type',
                                multiple_consumers => TRUE);
END;
/

BEGIN
 DBMS_AQADM.CREATE_QUEUE (queue_name =>     'orders_msg_queue',
                          queue_table =>    'orders_msg_qt',
                          queue_type =>     DBMS_AQADM.NORMAL_QUEUE,
                          max_retries =>    0,
                          retry_delay =>    0,
                          retention_time => 1209600,
                          dependency_tracking => FALSE,
                          comment =>        'Test Object Type Queue',
                          auto_commit =>    FALSE);
END;
/

BEGIN
 DBMS_AQADM.START_QUEUE('orders_msg_queue');
END;
/
