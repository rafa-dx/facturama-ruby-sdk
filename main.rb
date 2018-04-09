require_relative "../facturama_gem/lib/facturama"
require 'json'


# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURACION DEL ENTORNO DE LA API
def create_api_instance
  facturama_user='pruebas'
  facturama_password='pruebas2011'
  is_development = true             # true = Modo de pruebas / sandbox,   false = Modo de Producción (Timbrado real)


  #Creacion de una instancia de FacturamaApi
  Facturama::FacturamaApi.new(facturama_user,facturama_password,is_development)
end




# ---------------------------------------------------------------------------------------------------------------------
# EJEMPLO DEL SERVICIO DE CLIENTES
# - Listado  de clientes
# - Agregar cliente
# - Obtener cliente específico y editarlo
def sample_clients(facturama)

  sample_clients_list(facturama)    # Listar todos los clientes

  new_client = sample_clients_create(facturama)  # Agregar cliente
  client_id = new_client['Id']                    # Id del cliente recientemente agregado

  sample_clients_retrieve_and_update(facturama, client_id)

  sample_clients_remove(facturama, client_id)

end



# Obtiene el listado de clientes y muestra la cantidad de los mismos
def sample_clients_list(facturama)
  puts "===== Obtener los clientes - Inicio ====="

  lst_clients = facturama.clients.list      # Se obtiene una lista con todos los clientes
  lst_clients_count = lst_clients.count         # Cantidad inicial de clientes



  puts "Cantidad inicial de clientes: " + lst_clients_count.to_s

  puts "===== Obtener los clientes - Fin ====="
end



# Agrega un cliente
def sample_clients_create(facturama)
  puts "===== Agregar cliente - Inicio ====="

  facturama.clients.create(Facturama::Models::Client.new(
      {   Email: "info@pedroperez.net",
          Rfc: "RODJ899315654",
          CfdiUse: "P01",
          Name: "Pedro Perez Development Environment",

          Address: {Country: "MEXICO",
                    ExteriorNumber: "1230",
                    InteriorNumber: "B",
                    Locality: "San Luis",
                    Municipality: "San Luis Potosí",
                    Neighborhood: "Lomas 4ta",
                    State: "San Luis Potosí",
                    Street: "Cañada de Gomez",
                    ZipCode: "78220"
          }
      }))

  puts "===== Agregar cliente - Fin ====="
end



# Obtiene un cliente específico, lo edita y lo guarda
def sample_clients_retrieve_and_update(facturama, client_id)

  puts "===== Obtener cliente y editarlo - Inicio ====="

  # Se obtiene el cliente con el Id especificado
  specific_client = facturama.clients.retrieve(client_id)


  # Se ha encontrado un cliente con ese Id
  if specific_client != nil then

    puts "Specific Client: "
    puts JSON[specific_client]

    # Edición del campo RFC
    specific_client['Rfc'] = "XAXX010101000"
    specific_client['Email'] = "wm@joseromero.net"
    facturama.clients.update(specific_client, client_id)


    # Se obtiene nuevamente el cliente para confirmar que ha cambiado
    specific_client = facturama.clients.retrieve(client_id)

    if specific_client['Rfc'] == "XAXX010101000" then
        puts "Cliente editado, ahora su RFC es XAXX010101000"
    else
        puts "Error al editar cliente"
    end
  end


  puts "===== Obtener cliente y editarlo - Fin ====="
end



# Elimina un cliente
def sample_clients_remove(facturama, client_id)

  puts "===== Eliminar cliente - Inicio ====="

  specific_client = facturama.clients.remove(client_id)

  puts "Cliente eliminado: "
  puts JSON[specific_client]

  puts "===== Eliminar cliente - Fin ====="

end





# ---------------------------------------------------------------------------------------------------------------------
# EJEMPLO DEL SERVICIO DE PRODUCTOS
def sample_products( facturama )
    #sample_products_list(facturama)                     # Listar todos los productos


    new_product = sample_products_create(facturama)     # Agregar producto
    #product_id = new_product['Id']                      # Id del producto recientemente agregado

    #sample_client_retrieve_and_update(facturama, product_id)

    #sample_client_remove(facturama, product_id)

end



# Obtiene el listado de productos y muestra la cantidad de los mismos
def sample_products_list(facturama)
    puts "===== Obtener los productos - Inicio ====="

    lst_products = facturama.products.list       # Se obtiene una lista con todos los productos
    lst_products_count = lst_products.count       # Cantidad inicial de productos

    puts "Cantidad inicial de productos: " + lst_products_count.to_s

    puts "===== Obtener los productos - Fin ====="
end



# Agrega un cliente
def sample_products_create(facturama)
    puts "===== Agregar producto - Inicio ====="

    unit = facturama.catalog.units("servicio").first                        # La primera unidad que tenga que ver con servicio
    prod = facturama.catalog.products_or_services("desarrollo").first       # Se toma el primer producto o servicio



    product_model = Facturama::Models::Product.new(
        {
            Unit: "Servicio",
            UnitCode: unit['Value'],
            IdentificationNumber: "WEB003",
            Name: "Sitio Web CMS",
            Description: "Desarrollo e implementación de sitio web empleando un CMS",
            Price: 6500.0,
            CodeProdServ: prod['Value'],
            CuentaPredial: "123",

            Taxes: [
                {
                    Name: "IVA",
                    Rate: 0.16,
                    IsRetention: false
                },

                {
                    Name: "ISR",
                    IsRetention: true,
                    Total: 0.1
                },

                {
                    Name: "IVA",
                    IsRetention: true,
                    Total: 0.106667
                }
            ]
        }
    )

    product = facturama.products.create(product_model)

    puts "Se creo exitosamente un producto con el id: " + product['Id']


    facturama.products.delete( product['Id'] )

    puts "===== Agregar producto - Fin ====="
end








# ---------------------------------------------------------------------------------------------------------------------
# EJEMPLO DEL SERVICIO DE CFDI
def sample_cfdis( facturama )
    puts "===== Ejemplo de CFDI - Inicio ====="

    # Se obtiene la moneda con el valor "MXN"
    lst_currencies = facturama::catalog.currencies
    currency = lst_currencies.select {|currency| currency["Value"] == "MXN" }.first


    # Creacion del cfdi en su forma general (sin items / productos) asociados
    cfdi_model = sample_cfdis_create(facturama, currency)

    # Agregar los items que lleva el cfdi ( para este ejemplo, se agregan con datos aleatorios)
    add_items_to_cfdi(facturama, currency, cfdi_model)

    # Creación del CFDI mediante la API, para su creación
    cfdi = facturama.cfdis.create(cfdi_model)
    cfdi_uuid = cfdi['Complement']['TaxStamp']['Uuid']
    puts "Se creó exitosamente el cfdi con el folio fiscal:  " + cfdi_uuid

    # Descarga de los arvhivos PDF y XML del cfdi recien creado
    file_path = "factura" + cfdi_uuid
    facturama.cfdis.save_pdf( file_path + ".pdf",  id)
    facturama.cfdis.save_xml( file_path + ".xml",  id)

    # Se elmina el cfdi recien creado
    facturama.cfdis.remove(cfdi['Id'])
    puts "Se elminó exitosamente el cfdi con el folio fiscal: " + cfdi_uuid


    # Consulta de cfdi por palabra clave o Rfc



    puts "===== Ejemplo de CFDI - Fin ====="
end



def sample_cfdis_create(facturama, currency)

    # Nombre para el CFDI, para el ejemplo, tomado el primero de la lista del catálogo de nombres en el PDF
    name_for_pdf = facturama.catalog.name_ids.first; # Nombre en el pdf: "Factura"

    # Método de pago
    payment_method = facturama.catalog.payment_methods.select {|method| method["Name"] == "Pago en una sola exhibición" }.first


    # Forma de pago
    payment_form = facturama.catalog.payment_forms.select {|method| method["Name"] == "Efectivo" }.first


    # Cliente (se toma como cliente el "cliente generico", aquel que tiene el RFC genérico),
    #(como los clientes son exclusivos para cada usuario, se debe previamente dar de alta este cliente)
    client = facturama.clients.list.select {|client| client["Rfc"] == "XAXX010101000" }.first


    # Lugar de expedición
    branch_office = facturama.branch_office.list.first

    # Fecha de emision (ahora mismo)
    date = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    cfdi = Facturama::Models::Cfdi.new(
        {
            NameId: name_for_pdf['Value'],
            CfdiType: Facturama::CfdiType::INGRESO,
            PaymentForm: payment_form['Value'],
            PaymentMethod: payment_method['Value'],
            Currency: currency['Value'],
            Date: date,
            ExpeditionPlace: branch_office['Address']['ZipCode'],
            Receiver: {
                CfdiUse: client['CfdiUse'],
                Name: client['Name'],
                Rfc: client['Rfc']
            },
            Items: []
        }
    )


end


def add_items_to_cfdi(facturama, currency, cfdi)

    lst_products = facturama.products.list
    lst_products_size = lst_products.length

    n_items = (rand( lst_products.length ) % 10) + 1

    decimals = currency['Decimals'].to_i

    # Lista de conceptos para el CFDI
    lst_items = Array.new


    n_begin = lst_products_size - 1 - n_items

    for index in n_begin..lst_products_size

        product = lst_products[index]        # Un producto cualquiera

        if( product.nil? )
            break

        end

        quantity = rand(5) + 1          # una cantidad aleatoria de elementos de este producto

        discount = product['Price'] % ( product['Price']) == 0 ? 1 : rand( (product['Price'].to_i ) )
        subtotal = ( product['Price'] * quantity).round(decimals)    # Redondeo de acuerdo a la moneda



        item = Facturama::Models::Item.new({
            ProductCode: product['CodeProdServ'],
            UnitCode: product['UnitCode'],
            Unit: product['Unit'],
            Description: product['Description'],
            IdentificationNumber: product['IdentificationNumber'],
            Quantity: quantity,
            Discount: discount.round(decimals),
            UnitPrice: product['Price'].round(decimals),
            Subtotal: subtotal,
            Taxes: nil

        })


        base_amount = (subtotal - discount).round(decimals)
        taxes = product['Taxes'].map { |t|
            Facturama::Models::Tax.new(
                 Name: t['Name'],
                 IsQuota: t['IsQuota'],
                 IsRetention: t['IsRetention'],
                 Rate: t['Rate'].to_f.round(decimals),
                 Base: base_amount,
                 Total: (base_amount * t['Rate'].to_f).round(decimals)
            )
         }

        retentions_amount = 0
        transfers_amount = 0
        if taxes.length > 0
            item.Taxes = taxes
            # Calculo del monto total del concepto, tomando en cuenta los impuestos
            retentions_amount = item.Taxes.select { |tax| tax.IsRetention  }.sum(&:Total)
            transfers_amount = item.Taxes.select { |tax| ! tax.IsRetention  }.sum(&:Total)

        end

        item.Total = (item.Subtotal - item.Discount  + transfers_amount - retentions_amount).round(decimals)

        lst_items.push(item)

    end

    cfdi.Items = lst_items

end









puts "============================================================"
puts "                    FACTURAMA SDK   #{Facturama::VERSION}"
puts "============================================================"


# Creación de una instacia de la API Facturama, configurado con los datos del usuario de pruebas
facturama = create_api_instance



# Invocaciones a los ejemplos de uso de los servicios de Facturama API
begin
    #sample_clients(facturama)          # Servicio de cliente

    #sample_products(facturama)          # Servicio de productos

    sample_cfdis(facturama)              # Servicio de CFDI





rescue FacturamaException => ex
    puts "----------- EXCEPCIONES -----------"
    puts " * " + ex.message

    ex.details.each do |item|
        puts "#{item[0]}: " + item[1].join(",")
    end





rescue Exception => ex
    puts "----------- EXCEPCIONES -----------"
    puts " * " + ex.to_s
    end


