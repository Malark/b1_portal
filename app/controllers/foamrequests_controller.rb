class FoamrequestsController < ApplicationController
  before_action :set_request, only: [:edit, :update, :delete_request, :approve_request, :approve_request_index, :prepare_request_index, :prepare_component, :set_prepared_summary, :use_prepared_request, :use_prepared_request_step2, :use_prepared_request_step3]

  Requested_Material = Struct.new(:ItemCode, :ItemName, :requested, :prepared, :batch_managed, :material_type, :status)
  

  def index
    @foamrequests = KOM_HABIGENYLES.all_open
    session[:requested_materials] = []
    #@igroups_all = Igroup.order('igroups.name ASC').all
    #@foamrequest_search = KOM_HABIGENYLES.multiple_search(session[:igroup_id], params[:search])
  end


  def edit
  end


  def delete_request
    if @request.U_STATUS == 'O'
      @request.destroy
      flash[:danger] = "A kiválaszottt alapanyag igény végleges törlése sikeresen megtörtént!"
    else
      flash[:danger] = "Sikerltelen törlési kísérlet! Csak új igényt lehet törölni, jóváhagyott, előkészített vagy lezárt tétel nem törölhető!"
    end  
    redirect_to foamrequests_path
  end


  #----------------------------------------------------- New request

  def new_foam_request_index
    @actu_step = 1
    @foaming_machines_groups = Gepek.all
  end


  def set_parameters
    if (params[:foaming_machine][:machines].blank? || params[:product_itemcode].blank?)
      flash.now[:danger] = "Habosító gép és gyártandó termék kiválasztása kötelező!"
      @actu_step = 1
      @foaming_machines_groups = Gepek.all
    else
      #set the foaming machine
      @foam_machine = Gepek.search_item(params[:foaming_machine][:machines])
      if @foam_machine == nil
        flash.now[:danger] = "Nem létező habosító gép ID: #{params[:foaming_machine][:machines]}"
        @actu_step = 1
        @foaming_machines_groups = Gepek.all
      else
        session[:foaming_machine_id] = params[:foaming_machine][:machines]
        #searching for product itemname
        itemcode = params[:product_itemcode]
        s_itemcode = params[:product_itemcode] + '-S'
        @item = OITM.search_item(itemcode)
        if @item == nil
          flash.now[:danger] = "Nem létező cikkszám: #{itemcode}"
          @actu_step = 1
          @foaming_machines_groups = Gepek.all
        else
          #Check foam system of the product
          @foam_system = OITM.search_item(@item["U_HABRENDSZER"])
          if @foam_system == nil
            flash.now[:danger] = "Hibás vagy hiányzó habrendszer a termék törzsadatokban!}"
            @actu_step = 1
            @foaming_machines_groups = Gepek.all
          else
            error = false
            @error_message = ''
            session[:errors] = ''
            session[:product_itemcode] = itemcode
            session[:foam_system] = @item["U_HABRENDSZER"]

            #Foam system analysis
            @iso_component = ITT1.search_iso_component(@item["U_HABRENDSZER"])
            if @iso_component == nil
              error = true
              @error_message += "A #{session[:foam_system]} habrendszerben nincs ISO komponens definiálva! *** "
              session[:errors] += "* Nincs ISO komponens a habrendszerben "
            end
            @poliol_component = ITT1.search_poliol_component(@item["U_HABRENDSZER"])
            if @poliol_component == nil
              error = true
              @error_message += "A #{session[:foam_system]} habrendszerben nincs POLIOL komponens definiálva! *** "
              session[:errors] += "* Nincs POLIOL komponens a habrendszerben "
            end
            @additives = ITT1.search_additives(@item["U_HABRENDSZER"])

            #Are there opened production orders?
            @prod_orders = OWOR.search_opened_production_orders(s_itemcode)
            if @prod_orders == nil
              error = true
              @error_message += "A #{s_itemcode} cikknek nincsenek nyitott gyártási rendelései! "
              session[:errors] += "* Nincs nyitott gyártási rendelés "
            end
      
            #Are the two foam systems equivalent?
            if @item["U_HABRENDSZER"] != @foam_machine["U_AKTUHABRENDSZER"]
              error = true
              @error_message += "A #{s_itemcode} termék habrendszere (#{@item["U_HABRENDSZER"]}) nem egyezik meg a gépben tárolt habrendszerrel (#{@foam_machine["U_AKTUHABRENDSZER"]})!  *** "
              session[:errors] += "* A termék habrendszere (#{@item["U_HABRENDSZER"]}) eltér a gép habrendszerétől (#{@foam_machine["U_AKTUHABRENDSZER"]})"
            end
            @actu_step = 2
          end
        end
      end
    end
    respond_to do |format|
      format.js { render partial: 'request_foam' }
    end    
  end


  def select_quantities
    @actu_step = 3
    respond_to do |format|
      format.js { render partial: 'request_foam' }
    end    
  end

  def set_quantities
    if ((params[:iso_qty].blank? || params[:poliol_qty].blank?) || (params[:iso_qty].to_i < 0 || params[:poliol_qty].to_i < 0))
      flash.now[:danger] = "Az igényelt mennyiség mező nem lehet üres vagy negatív!"
      @actu_step = 3
    else
      if (params[:iso_qty].to_i == 0 && params[:poliol_qty].to_i == 0)
        flash.now[:danger] = "Legalább az egyik komponensből kötelező igénylést leadni!"
        @actu_step = 3
      else
        #if both material is applied at hte same time, then two new records need to be created
        iso_result = true
        poliol_result = true
        if params[:iso_qty].to_i > 0 
          iso_result = write_data(params[:iso_qty].to_i, 0)
          puts iso_result
        end
        # write polior record only if there was no porblem with the iso component
        if (iso_result == true and params[:poliol_qty].to_i > 0)
          poliol_result = write_data(0, params[:poliol_qty].to_i)
          puts poliol_result
        end

        if (iso_result == true and poliol_result == true)
          @actu_step = 4
        else
          @actu_step = 3
          flash.now[:danger] = "Sikertelen mentési kísérlet az adatbázisba! Ismételje meg a folyamatot!"
        end
      end
    end

    respond_to do |format|
      format.js { render partial: 'request_foam' }
    end        
  end


  def write_data(iso_qty, poliol_qty)
    last = KOM_HABIGENYLES.generate_charge_nr
    if last == nil
      actual_nr = 0
    else
      if last["U_SARZSSZAM"] == nil
        actual_nr = 0
      else
        actual_nr = last["U_SARZSSZAM"].to_i
      end
    end
    new_nr = actual_nr + 1
    d = DateTime.now
    request = KOM_HABIGENYLES.new
    request.U_SARZSSZAM = new_nr.to_s.rjust(5, '0')
    request.U_STATUS = 'O'  # open status
    request.U_GEP_ID = session[:foaming_machine_id]
    request.U_FOCIKKSZAM = session[:product_itemcode]
    request.U_HABRENDSZER = session[:foam_system]
    request.U_ISO_MENNYISEG = iso_qty
    request.U_POLIOL_MENNYISEG = poliol_qty
    request.U_IGENYDATUM = d.strftime "%Y-%m-%d  %H:%M:%S"
    request.U_IGENYLO = current_user.username  
    request.U_CreateDate = d.strftime "%Y-%m-%d  %H:%M:%S"  
    request.U_MEGJEGYZES = session[:errors]
    if request.save
      return true
    else
      return false
    end  
  end  

#----------------------------------------------------- Approve request  


  def approve_request
    if @request.U_STATUS == 'O'
      redirect_to approve_request_index_path(:id =>  @request.Code)    
    else
      flash[:danger] = "HIBA! Csak 'új igények' státuszú tétel hagyható jóvá!"
      redirect_to foamrequests_path
    end  
  end


  def approve_request_index
    @error_message = ''
    #set the foaming machine
    @foam_machine = Gepek.search_item(@request["U_GEP_ID"])
    if @foam_machine == nil
      @error_message = "Nem létező habosító gép ID: #{@request["U_GEP_ID"]} "
      @actu_step = 9
    else
      #searching for product itemname
      itemcode = @request["U_FOCIKKSZAM"]
      s_itemcode = @request["U_FOCIKKSZAM"] + '-S'
      @item = OITM.search_item(itemcode)
      if @item == nil
        @error_message = "Nem létező cikkszám: #{itemcode}"
        @actu_step = 9
      else
        #Check foam system of the product
        @foam_system = OITM.search_item(@item["U_HABRENDSZER"])
        if @foam_system == nil
          @error_message = "Hibás vagy hiányzó habrendszer a termék törzsadatokban!"
          @actu_step = 9
        else
          @error_message = ''

          #Foam system analysis
          @iso_component = ITT1.search_iso_component(@item["U_HABRENDSZER"])
          if @iso_component == nil
            @error_message += "A #{@item["U_HABRENDSZER"]} habrendszerben nincs ISO komponens definiálva! *** "
          end
          @poliol_component = ITT1.search_poliol_component(@item["U_HABRENDSZER"])
          if @poliol_component == nil
            @error_message += "A #{@item["U_HABRENDSZER"]} habrendszerben nincs POLIOL komponens definiálva! *** "
          end
          @additives = ITT1.search_additives(@item["U_HABRENDSZER"])

          #Are there opened production orders?
          @prod_orders = OWOR.search_opened_production_orders(s_itemcode)
          if @prod_orders == nil
            @error_message += "A #{s_itemcode} cikknek nincsenek nyitott gyártási rendelései! "
          end
    
          #Are the two foam systems equivalent?
          if @item["U_HABRENDSZER"] != @foam_machine["U_AKTUHABRENDSZER"]
            @error_message += "A #{s_itemcode} termék habrendszere (#{@item["U_HABRENDSZER"]}) nem egyezik meg a gépben tárolt habrendszerrel (#{@foam_machine["U_AKTUHABRENDSZER"]})!  *** "
          end
    
          @actu_step = 1
        end
      end
    end
  end


  def set_approved
    @request = KOM_HABIGENYLES.find(params[:id])
    KOM_HABIGENYLES.update_approved_request(@request.Code, current_user.username)
    @actu_step = 2
    respond_to do |format|
      format.js { render partial: 'approve_request' }
    end      
  end


#----------------------------------------------------- Prepare request by warehouse


  def prepare_request_index
    if (@request.U_STATUS != 'A' && @request.U_STATUS != 'I')
      flash[:danger] = "HIBA! Csak 'Jóváhagyva' vagy 'Folyamatban' státuszú tétel készíthető össze!"
      redirect_to foamrequests_path
    end       
    puts "GGGGGGGGGGGGGGGGGGGGGGG"
    #set main parameters
    session[:foam_type] = ''
    session[:foam_warehouse] = '1_alapW3'
    session[:material] = ''
    @asked_quantity = 0
    if @request.U_ISO_MENNYISEG.to_i > 0
      session[:foam_type] = 'ISO'
      @asked_quantity = @request.U_ISO_MENNYISEG.to_i
    else
      session[:foam_type] = 'POLIOL'
      @asked_quantity = @request.U_POLIOL_MENNYISEG.to_i
    end
    #searching for product OITM record
    itemcode = @request.U_FOCIKKSZAM
    @item = OITM.search_item(itemcode)
    if @item == nil
      flash[:danger] = "Nem létező termék cikkszám: #{itemcode}! "
      redirect_to foamrequests_path
    end

      
    @components = KOM_HABIGENY_TETEL.find_components(@request.U_SARZSSZAM)
    if @components == nil
      puts "UUUUUUUUUUUUUUUUUURRRRRRRRRRRES"
      # When we open the request very first time, need to check prerequisites and fill the detail table up

      # 1. check prerequisites
      @error_message = ''
      #Check requested quantities
      if @asked_quantity == 0
        @error_message += "Az igényelt ISO és POLIOL mennyiség is 0! "
      end
      #Check the foam system presence
      @foam_system = OITM.search_item( @request.U_HABRENDSZER)
      if @foam_system == nil
        @error_message += "A (#{@request.U_HABRENDSZER}) habrendszer nem található meg a törzsadatokban! "
      end
      #Foam system analysis
      @iso_component = ITT1.search_iso_component(@item["U_HABRENDSZER"])
      if @iso_component == nil
        @error_message += "A #{@item["U_HABRENDSZER"]} habrendszerben nincs ISO komponens definiálva! "
      end
      @poliol_component = ITT1.search_poliol_component(@item["U_HABRENDSZER"])
      if @poliol_component == nil
        @error_message += "A #{@item["U_HABRENDSZER"]} habrendszerben nincs POLIOL komponens definiálva! "
      end
      @additives = ITT1.search_additives(@item["U_HABRENDSZER"])

      # 2. fill up details table
      if @error_message > ''  
        flash[:danger] = @error_message
        redirect_to foamrequests_path
      else  #if everything is OK
        # Requested_Material = Struct.new(:ItemCode, :ItemName, :requested, :prepared, :batch_managed, :material_type, :status)
        @requested_materials = []
        # Collect preparable items
        if session[:foam_type] == 'ISO'
          #oitw_onhand = OITW.onhand(session[:foam_warehouse], @iso_component["ItemCode"])
          #if oitw_onhand == nil
          #  stock_amount = 0
          #else
          #  stock_amount = oitw_onhand["OnHand"]
          #end
          material = Requested_Material.new(  @iso_component["ItemCode"], 
                                              @iso_component["ItemName"], 
                                              @request.U_ISO_MENNYISEG.to_i, 
                                              0, 
                                              @iso_component["ManBtchNum"], 
                                              'ISO', 
                                              'Nyitott')
          @requested_materials.push(material)
          component = KOM_HABIGENY_TETEL.new
          component.U_IGENY_SARZSSZAM = @request.U_SARZSSZAM
          component.U_ITEMCODE = @iso_component["ItemCode"]
          component.U_ITEMNAME = @iso_component["ItemName"]
          component.U_REQUESTED_QTY = @request.U_ISO_MENNYISEG.to_i
          component.U_PREPARED_QTY = 0
          component.U_MATERIAL_TYPE = 'ISO'
          component.U_STATUS = 'O'
          component.U_BATCH_MANAGED = @iso_component["ManBtchNum"]
          component.save
        else
          #oitw_onhand = OITW.onhand(session[:foam_warehouse], @poliol_component["ItemCode"])
          #if oitw_onhand == nil
          #  stock_amount = 0
          #else
          #  stock_amount = oitw_onhand["OnHand"]
          
        #end
          material = Requested_Material.new(  @poliol_component["ItemCode"], 
                                              @poliol_component["ItemName"], 
                                              @request.U_POLIOL_MENNYISEG.to_i, 
                                              0, 
                                              @poliol_component["ManBtchNum"], 
                                              'POLIOL', 
                                              'Nyitott')
          @requested_materials.push(material)
          component = KOM_HABIGENY_TETEL.new
          component.U_IGENY_SARZSSZAM = @request.U_SARZSSZAM
          component.U_ITEMCODE = @poliol_component["ItemCode"]
          component.U_ITEMNAME = @poliol_component["ItemName"]
          component.U_REQUESTED_QTY = @request.U_POLIOL_MENNYISEG.to_i
          component.U_PREPARED_QTY = 0
          component.U_MATERIAL_TYPE = 'POLIOL'
          component.U_STATUS = 'O'
          component.U_BATCH_MANAGED = @poliol_component["ManBtchNum"]
          if component.save     
            puts "Sikeres POLIOL felírás!!!!!!"
          else
            puts "Hiba a POLIOL felírása közben: #{row["ItemCode"]}! "
          end
          #additives
          if @additives != nil
            @additives.each do |row|
              #oitw_onhand = OITW.onhand(session[:foam_warehouse], row["ItemCode"])
              #if oitw_onhand == nil
              #  stock_amount = 0
              #else
              #  stock_amount = oitw_onhand["OnHand"]
              #end
              #count the amount of the additives
              requested_qty = @request.U_POLIOL_MENNYISEG.to_i
              if @poliol_component["Quantity"] > 0
                ratio = row["Quantity"] / @poliol_component["Quantity"]
                additive_qty = requested_qty * ratio
              else
                additive_qty = 0
              end
              material = Requested_Material.new(row["ItemCode"], 
                                                row["ItemName"], 
                                                additive_qty.round(2), 
                                                0,
                                                row["ManBtchNum"], 
                                                'Adalék', 
                                                'Nyitott')
              @requested_materials.push(material)
              component = KOM_HABIGENY_TETEL.new
              component.U_IGENY_SARZSSZAM = @request.U_SARZSSZAM
              component.U_ITEMCODE = row["ItemCode"]
              component.U_ITEMNAME = row["ItemName"]
              component.U_REQUESTED_QTY = additive_qty.round(2) 
              component.U_PREPARED_QTY = 0
              component.U_MATERIAL_TYPE = 'Adalék'
              component.U_STATUS = 'O'
              component.U_BATCH_MANAGED = row["ManBtchNum"]
              component.U_ESD_ADALEK = row["QryGroup44"]
              if component.save     
                puts "Sikeres Component felírás!!!!!!"
              else
                puts "Hiba a komponens felírása közben: #{row["ItemCode"]}! "
              end
            end
          end
        end
        session[:requested_materials] = @requested_materials
        @components = KOM_HABIGENY_TETEL.find_components(@request.U_SARZSSZAM)
      end
    else
      # check wether all components are prepared
      error = false
      @components.each do |component|
        if component["U_STATUS"] != 'C'
          error = true 
        end
      end

      if error == true
        @all_components_prepared = false
      else
        @all_components_prepared = true
      end
      
    end

  end
  

  def prepare_component
    puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    puts @request.U_POLIOL_MENNYISEG

    # check the existing requests: at the same time only one request is allowed to prepare
    requests_in_progress = KOM_HABIGENYLES.find_requests_in_progress(@request.U_SARZSSZAM)
    if requests_in_progress != nil
      first_record = requests_in_progress.first
      flash[:danger] = "Figyelem! Az előkészítés nem végezhető el, amíg van másik megkezdett előkészítési folyamat (ID: #{first_record["U_SARZSSZAM"]})!"
      redirect_to prepare_request_index_path(:id => @request)       
    end

    @component = KOM_HABIGENY_TETEL.find(params[:detail_table_id])
    puts @component["U_ITEMNAME"]
    @asked_quantity = 0
    if @request.U_ISO_MENNYISEG.to_i > 0
      session[:foam_type] = 'ISO'
      @asked_quantity = @request.U_ISO_MENNYISEG.to_i
    else
      session[:foam_type] = 'POLIOL'
      @asked_quantity = @request.U_POLIOL_MENNYISEG.to_i
    end
    # searching for product OITM record
    itemcode = @request.U_FOCIKKSZAM
    @item = OITM.search_item(itemcode)
    if @item == nil
      flash[:danger] = "Nem létező termék cikkszám: #{itemcode}! "
      redirect_to prepare_request_index_path(:id => @request) 
    end

    # In case of marking for use a batch or a unit
    if params[:sender] == 'usage_batch'
      puts "Batch egység felhasználás történt"
      puts params[:row_id]
      puts params[:detail_table_id]
      if @component["U_BATCH_MANAGED"] == 'Y'
        @selected_unit = OBBQ.find_batch_by_absentry(@request.U_SARZSSZAM, params[:row_id])
      else
        @selected_unit = OIBQ.find_unit_by_absentry(@request.U_SARZSSZAM, params[:row_id])
      end
      if @selected_unit == nil
        puts "HIBA! Nem található sarzs vagy tárolóhelyes tétel"
      else
        unit = @selected_unit.first
        # Count the right needed amount of the selected batch or unit (based on the requested amount)
        puts 'Helyes mennyiség számolás'
        puts @component["U_REQUESTED_QTY"]
        puts @component["U_PREPARED_QTY"]
        puts unit["U_SARZSSZAM"]
        requested_qty = @component["U_REQUESTED_QTY"]
        prepared_qty = @component["U_PREPARED_QTY"]
        needed_qty = requested_qty - prepared_qty
        unit_available_qty = unit["OnHandQty"]
        if needed_qty <= 0
          # If all the requested qty is selected, don§'t do anything but an error message
          flash[:danger] = "A #{@component["U_ITEMCODE"]} komponensből már a teljes szükséges mennyiség ki lett jelölve! Újabb tétel hozzáadása nem lehetséges!"
          redirect_to prepare_request_index_path(:id => @request) 
        else
          if needed_qty >= unit_available_qty
            marked_qty = unit_available_qty
          else
            marked_qty = needed_qty
          end

          # Add record to KOM_HABIGENY_MOZGAS table
          transaction = KOM_HABIGENY_MOZGAS.new
          transaction.U_AbsEntry = unit["AbsEntry"]
          transaction.U_Source = unit["Source"]
          transaction.U_ItemCode = unit["ItemCode"]
          transaction.U_ItemName = unit["ItemName"]
          transaction.U_Batch_Managed = @component["U_BATCH_MANAGED"]
          transaction.U_DistNumber = unit["DistNumber"]
          transaction.U_WhsCode = unit["WhsCode"]
          transaction.U_SL1Code = unit["SL1Code"]
          transaction.U_InDate = unit["InDate"]
          transaction.U_ExpDate = unit["ExpDate"]
          transaction.U_MarkedQty = marked_qty
          #transaction.U_Status = ''
          transaction.U_IGENY_SARZSSZAM = @request.U_SARZSSZAM
          transaction.U_MATERIAL_TYPE = @component["U_MATERIAL_TYPE"]
          transaction.save

          # Update component's U_PREPARED_QTY field
          @component["U_PREPARED_QTY"] = prepared_qty + marked_qty
          if @component["U_PREPARED_QTY"] >= @component["U_REQUESTED_QTY"] 
            @component["U_STATUS"] = 'C'
          else
            @component["U_STATUS"] = 'P'
          end  
          @component.save

          # Update request's status
          if @request.U_STATUS == 'A' 
            @request.U_STATUS = 'I'
            @request.save
          end
        end

      end
    end

    # In case of removing a mark from a batch or a unit
    if params[:sender] == 'remove_batch'
      puts "Batch egység törlés történt"
      #find_transaction_by_absentry(source, absentry)
      if @component["U_BATCH_MANAGED"] == 'Y'
        source = 'OBBQ'
      else
        source = 'OIBQ'
      end
      puts source
      puts params[:row_id]
      @unit = KOM_HABIGENY_MOZGAS.find_transaction_by_absentry(source, params[:row_id])
      if @unit == nil
        puts "Nincs meg a tétel"
      else
        unit = @unit.first
        puts "Tétel rekord megtalálva!!!"
        puts unit["Code"]

        # Update component's U_PREPARED_QTY field
        @component["U_PREPARED_QTY"] = @component["U_PREPARED_QTY"] - unit["U_MarkedQty"]
        if @component["U_PREPARED_QTY"] == 0
          @component["U_STATUS"] = 'O'
        elsif (@component["U_PREPARED_QTY"] > 0 and @component["U_PREPARED_QTY"] < @component["U_REQUESTED_QTY"])
          @component["U_STATUS"] = 'P'
        end
        @component.save

        # delete transaction record
        KOM_HABIGENY_MOZGAS.delete_transaction(unit["Code"])
                
      end  
    end

    # Building up batches and units struct to show them in a table
    if @component["U_BATCH_MANAGED"] == 'Y'
      @units = OBBQ.search_batches(@request.U_SARZSSZAM, @component["U_ITEMCODE"], session[:foam_warehouse])
    else
      @units = OIBQ.search_units(@request.U_SARZSSZAM, @component["U_ITEMCODE"], session[:foam_warehouse])
    end
    if @units == nil
      flash[:danger] = "Hiba! Nincs elérhető készlet!"
      redirect_to prepare_request_index_path(:id => @request) 
    else
      # Modify MarkedQty to 0 if not exists
      @units.each do |item|
        if item["U_MarkedQty"] == nil
          item["U_MarkedQty"] = 0
        end
        item["OnHandQty"] = item["OnHandQty"] - item["U_MarkedQty"]
      end
    end  
  end


  def set_prepared_summary
    error = false
    @components = KOM_HABIGENY_TETEL.find_components(@request.U_SARZSSZAM)
    if @components == nil
      error = true      
    else
      @components.each do |component|
        if component["U_STATUS"] != 'C'
          error = true 
        end
      end
    end
    @asked_quantity = 0
    if @request.U_ISO_MENNYISEG.to_i > 0
      session[:foam_type] = 'ISO'
      @asked_quantity = @request.U_ISO_MENNYISEG.to_i
    else
      session[:foam_type] = 'POLIOL'
      @asked_quantity = @request.U_POLIOL_MENNYISEG.to_i
    end
    itemcode = @request.U_FOCIKKSZAM
    @item = OITM.search_item(itemcode)
    if @item == nil
      flash[:danger] = "Nem létező termék cikkszám: #{itemcode}! "
      redirect_to prepare_request_index_path(:id => @request) 
    end
    if error == true
      flash[:danger] = "Folytatás nem lehetséges! Nincs összekészítve az összes komponens!"
      redirect_to prepare_request_index_path(:id => @request) 
    else
      @transactions = KOM_HABIGENY_MOZGAS.find_transactions_by_batch(@request.U_SARZSSZAM)
      if @transactions == nil
        flash[:danger] = "Folytatás nem lehetséges! Nem található egyetlen mozgás tétel sem!"
        redirect_to prepare_request_index_path(:id => @request) 
      end
    end
  end


  def summary_report
    @request = KOM_HABIGENYLES.find(params[:request_id])
    error = false
    @components = KOM_HABIGENY_TETEL.find_components(@request.U_SARZSSZAM)
    if @components == nil
      error = true      
    else
      @components.each do |component|
        if component["U_STATUS"] != 'C'
          error = true 
        end
      end
    end
    if error == true
      flash[:danger] = "Folytatás nem lehetséges! Nincs összekészítve az összes komponens!"
      redirect_to prepare_request_index_path(:id => @request) 
    else
      @transactions = KOM_HABIGENY_MOZGAS.find_transactions_by_batch(@request.U_SARZSSZAM)
      if @transactions == nil
        flash[:danger] = "Folytatás nem lehetséges! Nem található egyetlen mozgás tétel sem!"
        redirect_to prepare_request_index_path(:id => @request) 
      else
        #respond_to do |format|
        #  format.pdf do
          send_data generate_summary_report(@request, @transactions), filename: 'Alapanyag összesítés - ' + Time.now.strftime("%Y-%m-%d") + '.pdf', type: 'application/pdf', disposition: 'inline'
        #  end
        #end
      end
    end

  end

    #request.U_SARZSSZAM = actual_nr + 1
    #request.U_STATUS = 'O'  # open status
    #request.U_GEP_ID = session[:foaming_machine_id]
    #request.U_FOCIKKSZAM = session[:product_itemcode]
    #request.U_HABRENDSZER = session[:foam_system]
    #request.U_ISO_MENNYISEG = iso_qty
    #request.U_POLIOL_MENNYISEG = poliol_qty
    #request.U_IGENYDATUM = d.strftime "%Y-%m-%d  %H:%M:%S"
    #request.U_IGENYLO = current_user.username  
    #request.U_CreateDate = d.strftime "%Y-%m-%d  %H:%M:%S"  
    #request.U_MEGJEGYZES = session[:errors]

    #component.U_IGENY_SARZSSZAM = @request.U_SARZSSZAM
    #component.U_ITEMCODE = row["ItemCode"]
    #component.U_ITEMNAME = row["ItemName"]
    #component.U_REQUESTED_QTY = additive_qty.round(2) 
    #component.U_PREPARED_QTY = 0
    #component.U_MATERIAL_TYPE = 'Adalék'
    #component.U_STATUS = 'O'
    #component.U_BATCH_MANAGED = row["ManBtchNum"]   
    
    #transaction.U_AbsEntry = unit["AbsEntry"]
    #transaction.U_Source = unit["Source"]
    #transaction.U_ItemCode = unit["ItemCode"]
    #transaction.U_ItemName = unit["ItemName"]
    #transaction.U_Batch_Managed = @component["U_BATCH_MANAGED"]
    #transaction.U_DistNumber = unit["DistNumber"]
    #transaction.U_WhsCode = unit["WhsCode"]
    #transaction.U_SL1Code = unit["SL1Code"]
    #transaction.U_InDate = unit["InDate"]
    #transaction.U_ExpDate = unit["ExpDate"]
    #transaction.U_MarkedQty = marked_qty
    #transaction.U_IGENY_SARZSSZAM = U_SARZSSZAM    
    #transaction.U_MATERIAL_TYPE = @component["U_MATERIAL_TYPE"]

  def generate_summary_report(request, transactions)
    #report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'views', 'foamrequests', 'request_summary.tlf')
    report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'views', 'foamrequests', 'request_summary.tlf')

    report.start_new_page

    report.page.values print_date: Time.now
    report.page.values igeny_sarzsszam: request.U_SARZSSZAM
    report.page.values gep_id: request.U_GEP_ID
    report.page.values habtipus: session[:foam_type]
    report.page.values igenyelt_mennyiseg: session[:foam_type] == 'ISO' ? request.U_ISO_MENNYISEG.to_i.to_s + ' kg' : request.U_POLIOL_MENNYISEG.to_i.to_s + ' kg'

    # JAN13 - the 13rd character is a checksum!!!!!
    filled_batch_nr = request.U_SARZSSZAM.rjust(12, '0')
    #puts filled_batch_nr
    report.page.item(:jan_13).src(barcode(:ean_13, filled_batch_nr))    
    #report.page.item(:jan_13).src(barcode(:ean_13, '491234567890'))    
    #report.page.item(:jan_8).src(barcode(:ean_8, '4512345'))

    #sum_sum_amount = 0  #Bruttó összeg

    transactions.each do |transaction|
      report.list.add_row do |row|
     
        row.values tipus: transaction["U_MATERIAL_TYPE"],
          itemcode: transaction["U_ItemCode"],
          itemname: transaction["U_ItemName"],
          sarzsszam: transaction["U_DistNumber"],
          mennyiseg: transaction["U_MarkedQty"],
          lejarat_datum: transaction["U_ExpDate"]
          #tarhely: transaction["U_SL1Code"]
      end
    end

    report.list.on_footer_insert do |footer|
      # Szum mezők
      #footer.item(:sum_amount).value(sum_sum_amount)
    end

    report.generate
  end


  def barcode(type, data, png_opts = {})
    code = case type
    when :ean_13
      Barby::EAN13.new(data)
    when :ean_8
      Barby::EAN8.new(data)
    when :qr_code
      Barby::QrCode.new(data)
    end
    StringIO.new(code.to_png(png_opts))
  end  


  def finish_preparation
    @request = KOM_HABIGENYLES.find(params[:request_id]) 

    if params[:sap_document].blank?
      flash[:danger] = "Mentés nem lehetséges! A SAP átkönyvelési bizonylat számát kötelező megadni!"
      redirect_to set_prepared_summary_path(:id => @request.Code)
    else
      # Update request's status
      d = DateTime.now
      @request["U_STATUS"] = 'P'
      @request["U_SAP_BIZONYLAT"] = params[:sap_document]
      @request["U_RAKTAROS"] = current_user.username  
      @request["U_OSSZEKESZIT_DATUM"] = d.strftime "%Y-%m-%d  %H:%M:%S" 
      @request.save
      flash[:danger] = "Alapanyag igény (ID: #{@request["U_SARZSSZAM"]}) előkészítése sikeresen megtörtént!"
      redirect_to foamrequests_path 
    end
  end


#----------------------------------------------------- Use prepared materials 


  def use_prepared_request
    if @request.U_STATUS != 'P'
      flash.now[:danger] = "HIBA! Csak 'előkészített' státuszú tétel tölthető tartályba!"
      redirect_to foamrequests_path
    else
      #set the foaming machine
      @foam_machine = Gepek.search_item(@request["U_GEP_ID"])
      if @foam_machine == nil
        flash.now[:danger] = "Nem létező habosító gép ID: #{@request["U_GEP_ID"]} "
        redirect_to foamrequests_path
      else
        #searching for product itemname
        itemcode = @request["U_FOCIKKSZAM"]
        s_itemcode = @request["U_FOCIKKSZAM"] + '-S'
        @item = OITM.search_item(itemcode)
        if @item == nil
          flash.now[:danger] = "Nem létező cikkszám: #{itemcode}"
          redirect_to foamrequests_path
        else
          #Check foam system of the product
          @foam_system = OITM.search_item(@item["U_HABRENDSZER"])
          if @foam_system == nil
            flash.now[:danger] = "Hibás vagy hiányzó habrendszer a termék törzsadatokban!"
            redirect_to foamrequests_path
          else
            @error_message = ''
  
            #Foam system analysis
            @iso_component = ITT1.search_iso_component(@item["U_HABRENDSZER"])
            if @iso_component == nil
              @error_message += "A #{@item["U_HABRENDSZER"]} habrendszerben nincs ISO komponens definiálva! *** "
            end
            @poliol_component = ITT1.search_poliol_component(@item["U_HABRENDSZER"])
            if @poliol_component == nil
              @error_message += "A #{@item["U_HABRENDSZER"]} habrendszerben nincs POLIOL komponens definiálva! *** "
            end
            @additives = ITT1.search_additives(@item["U_HABRENDSZER"])
            @error = false
            #Are the two foam systems equivalent?
            if @item["U_HABRENDSZER"] != @foam_machine["U_AKTUHABRENDSZER"]
              @error = true
              @error_message += "A #{s_itemcode} termék habrendszere (#{@item["U_HABRENDSZER"]}) nem egyezik meg a gépben tárolt habrendszerrel (#{@foam_machine["U_AKTUHABRENDSZER"]})!  *** "
            end

            # collecting the components
            @esd_additives = false
            @components = KOM_HABIGENY_TETEL.find_components(@request.U_SARZSSZAM)
            if @components == nil
              flash.now[:danger] = "Nem található egyetlen összekészített komponens sem!"
              redirect_to foamrequests_path     
            else
              @components.each do |component|
                if component["U_STATUS"] != 'C'
                  flash.now[:danger] = "Nincs minden komponens összekészítve!"
                  redirect_to foamrequests_path     
                else
                  @components.each do |row|
                    if row["U_ESD_ADALEK"] == 'Y'
                      @esd_additives = true
                    end
                  end
                end
              end
            end
            @transactions = KOM_HABIGENY_MOZGAS.find_transactions_by_batch(@request.U_SARZSSZAM)
            if @transactions == nil
              flash[:danger] = "Folytatás nem lehetséges! Nem található egyetlen előkészített komponens sem!"
              redirect_to foamrequests_path
            end
            #container foam check
            if @request.U_ISO_MENNYISEG.to_i > 0
              if (@foam_machine["U_AKTU_ISO"] != nil and @foam_machine["U_AKTU_ISO"] != @iso_component["ItemCode"])
                @error = true
                @error_message += "Az összekészített ISO komponens (#{@iso_component["ItemCode"]}) nem egyezik meg az ISO tartályban jelenleg tárolt ISO cikkszámmal (#{@foam_machine["U_AKTU_ISO"]})!  *** "
              end
            else
              if (@foam_machine["U_AKTU_POLIOL"] != nil and @foam_machine["U_AKTU_POLIOL"] != @poliol_component["ItemCode"])
                @error = true
                @error_message += "Az összekészített POLIOL komponens (#{@poliol_component["ItemCode"]}) nem egyezik meg a POLIOL tartályban jelenleg tárolt POLIOL cikkszámmal (#{@foam_machine["U_AKTU_POLIOL"]})!  *** "
              end  
            end
          end
        end
      end
    end  
  end


  def use_prepared_request_step2
    # in case of ISO type we need to check the silicagel's condition 
    # in case of POLIOL we need to ask some measurements from the user in case of ESD additives
    @material_type = ''
    @esd_additives = false
    if @request.U_ISO_MENNYISEG.to_i > 0
      puts "type - iso"
      @material_type = 'ISO'
    else
      @material_type = 'POLIOL'
      puts "type - poliol"
      # searching for ESD additives
      @components = KOM_HABIGENY_TETEL.find_components(@request.U_SARZSSZAM)
      if @components == nil
        flash.now[:danger] = "Nem található egyetlen összekészített komponens sem!"
        redirect_to foamrequests_path     
      else
        @components.each do |row|
          if row["U_ESD_ADALEK"] == 'Y'
            @esd_additives = true
          end
        end
      end
    end
    puts @esd_additives
    # If the material is not ISO and not consists on ESD additives then we can contionue the process without asking any additional info from the user
    if (@material_type == 'POLIOL' && @esd_additives == false)
      redirect_to use_prepared_request_step3_path(:id => @request.Code, :additional_params => false)
    end
  end


  def use_prepared_request_step3
    error = false
    szilika_check = ''
    szilika_comment = ''
    esd_meres = 0.00
    main_component = ''
    if params[:additional_params] == 'true'
      # check if additional parameters are not empty
      # ISO Component parameters
      if @request.U_ISO_MENNYISEG.to_i > 0
        if params[:silica_gel].blank?
          error = true
        else
          szilika_check = params[:silica_gel]
          szilika_comment = params[:silica_note]
          if params[:silica_gel] == 'Nem'
            # check comment field
            if params[:silica_note].blank?
              error = true
            end
          end
        end
      else
        # POLIOL Component with ESD additives parameters
        if params[:esd_measurement].blank?
          error = true
        else
          esd_meres = params[:esd_measurement].to_f
          if ((params[:esd_measurement].to_f <= 0) || (params[:esd_measurement].to_f > 5))
            error = true
          end  
        end  
      end  
      if error == true
        flash[:danger] = "Hiányos, vagy hibás adat! ISO komponens eseténkérem válaszoljon a szilika-gél ellenőrzés kérdésre. Nem válasz esetén kötelező megjegyzést is írni! ESD komponens esetén a mért értéknek 0 és 5 MOhm között kell lennie. Ha a mért érték nagyobb 5-nél, szóljon az üzemvezetőnek!"
        redirect_to use_prepared_request_step2_path(:id => @request.Code)
      end
    end

    # Write data if no errors
    if error == false
      @foam_machine = Gepek.search_item(@request.U_GEP_ID)
      if @foam_machine == nil
        flash.now[:danger] = "Nem található gépszám! A betöltési folyamat nem foélytatható!"
        redirect_to foamrequests_path     
      end
      # 1. KOM_TARTALY_MOZGAS
      @components = KOM_HABIGENY_MOZGAS.find_components(@request.U_SARZSSZAM)
      if @components == nil
        flash.now[:danger] = "Nem található egyetlen összekészített komponens sem!"
        redirect_to foamrequests_path     
      else
        d = DateTime.now
        @components.each do |row|
          

          @transaction = KOM_TARTALY_MOZGAS.new
          @transaction.U_GEP_ID = @request["U_GEP_ID"]
          # In case of ISO
          if @request.U_ISO_MENNYISEG.to_i > 0
            # Determine the main component ID
            if row["U_MATERIAL_TYPE"] == 'ISO'
              main_component = row["U_ItemCode"]
            end
            @transaction.U_TARTALY_ID = @foam_machine["U_ISO_TARTALY_ID"]
            @transaction.U_TARTALY_TYPE = 'ISO'
            @transaction.U_GEP_HABCIKKSZAM = @foam_machine["U_AKTU_ISO"]
            @transaction.U_SZILIKA_CHECK = szilika_check
            @transaction.U_SZILIKA_COMMENT = szilika_comment
          else
            # Determine the main component ID
            if row["U_MATERIAL_TYPE"] == 'POLIOL'
              main_component = row["U_ItemCode"]
            end            
            @transaction.U_TARTALY_ID = @foam_machine["U_POLIOL_TARTALY_ID"]
            @transaction.U_TARTALY_TYPE = 'POLIOL'
            @transaction.U_GEP_HABCIKKSZAM = @foam_machine["U_AKTU_POLIOL"]
            @transaction.U_ESD_MERES = esd_meres
          end
          @transaction.U_GEP_HABRENDSZER = @foam_machine["U_AKTUHABRENDSZER"]
          @transaction.U_MOZGAS_TIPUS = 'BETÖLTÉS'
          @transaction.U_IGENY_SARZSSZAM = @request["U_SARZSSZAM"]
          @transaction.U_HABRENDSZER = @request["U_HABRENDSZER"]
          @transaction.U_ItemCode = row["U_ItemCode"]
          @transaction.U_ItemName = row["U_ItemName"]
          @transaction.U_Batch_Managed = row["U_Batch_Managed"]
          @transaction.U_MATERIAL_TYPE = row["U_MATERIAL_TYPE"]
          @transaction.U_DistNumber =  row["U_DistNumber"]
          @transaction.U_Quantity =  row["U_MarkedQty"]
          @transaction.U_ExpDate = row["U_ExpDate"]
          @transaction.U_USER = current_user.username  
          @transaction.U_CreateDate = d.strftime "%Y-%m-%d  %H:%M:%S"
          @transaction.save
          puts row["U_ItemCode"]
          puts 'MOZGAS FELIRAS KESZ'
        end
      end


      # 2. GEPEK
      #@foam_machine = Gepek.search_item(@request.U_GEP_ID)
      @foam_machine2 = Gepek.find(@foam_machine["Code"])
      @foam_machine2.U_UTOLSO_MOZGAS = d.strftime "%Y-%m-%d  %H:%M:%S"
      @foam_machine2.U_AKTUHABRENDSZER = @request["U_HABRENDSZER"]
      if @request.U_ISO_MENNYISEG.to_i > 0
        @foam_machine2.U_AKTU_ISO = main_component
      else
        @foam_machine2.U_AKTU_POLIOL = main_component
      end      
      @foam_machine2.save

      
      # 3. KOM_HABIGENYLES
      @request.U_STATUS = 'C'
      @request.U_BETOLTO_USER = current_user.username  
      @request.U_BETOLTES_DATUM = d.strftime "%Y-%m-%d  %H:%M:%S"        
      @request.save   
    end
  end


  private

  def set_request
    @request = KOM_HABIGENYLES.find(params[:id])
  end


end