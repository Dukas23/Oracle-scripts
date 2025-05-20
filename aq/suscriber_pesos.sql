-- Habilita la salida de mensajes en la consola para mostrar mensajes generados por DBMS_OUTPUT.PUT_LINE
SET SERVEROUTPUT ON

DECLARE
  -- Configuración para la operación de dequeue
  dequeue_options    dbms_aq.dequeue_options_t;
  -- Propiedades del mensaje que se va a procesar
  message_properties dbms_aq.message_properties_t;
  -- Identificador único del mensaje
  message_handle     RAW(16);
  -- Objeto del tipo orders_message_type que contiene los datos del mensaje
  message            aq_admin.orders_message_type;
BEGIN
    -- Configuración predeterminada para dequeue_options
    -- Consumidor que procesará los mensajes de la cola
    dequeue_options.consumer_name := 'PESOS_ORDERS';
    -- Configura la visibilidad del mensaje como inmediata
    dequeue_options.VISIBILITY := DBMS_AQ.IMMEDIATE;
    -- Tiempo de espera de 15 segundos para la operación de dequeue
    dequeue_options.WAIT       := 15;
    -- Procesar el primer mensaje disponible en la cola
    dequeue_options.navigation  := DBMS_AQ.FIRST_MESSAGE;
    
    -- Realiza la operación de dequeue
    DBMS_AQ.DEQUEUE (
        queue_name          => 'aq_admin.orders_msg_queue', -- Nombre de la cola
        dequeue_options     => dequeue_options,            -- Configuración de dequeue
        message_properties  => message_properties,         -- Propiedades del mensaje
        payload             => message,                    -- Carga útil del mensaje
        msgid               => message_handle);            -- Identificador único del mensaje
        
    -- Imprime un encabezado decorativo para los datos del mensaje
    dbms_output.put_line('+---------------+');
    dbms_output.put_line('| MESSAGE PAYLOAD |');
    dbms_output.put_line('+---------------+');
    
    -- Imprime los detalles del mensaje procesado
    dbms_output.put_line('- Order ID := ' ||  message.order_id); -- Identificador del pedido
    dbms_output.put_line('- Customer ID:= ' ||  message.customer_id); -- Identificador del cliente
    dbms_output.put_line('- Product Code:= ' || message.product_code); -- Código del producto
    dbms_output.put_line('- Order Details := ' || message.order_details); -- Detalles del pedido
    dbms_output.put_line('- Price in Pesos := ' || message.price); -- Precio en pesos
    dbms_output.put_line('- Region := ' || message.region_code); -- Región asociada al pedido
    
    -- Confirma la transacción para eliminar el mensaje de la cola
    COMMIT;
END;