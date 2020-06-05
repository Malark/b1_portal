class FoamrequestsController < ApplicationController
  before_action :set_request, only: [:edit, :update, :delete_request, :approve_request, :approve_request_index, :prepare_request, :use_prepared_request]
  

  def index
    @foamrequests = KOM_HABIGENYLES.all_open

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
    d = DateTime.now
    request = KOM_HABIGENYLES.new
    request.U_SARZSSZAM = actual_nr + 1
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


  def prepare_request
    if @request.U_STATUS == 'A'
      redirect_to prepare_request_index_path      
    else
      flash[:danger] = "HIBA! Csak jóváhagyott státuszú tétel készíthető össze!"
      redirect_to foamrequests_path
    end  
  end


#----------------------------------------------------- Use prepared materials 

  def use_prepared_request
    if @request.U_STATUS == 'P'
      redirect_to use_prepared_request_index_path      
    else
      flash[:danger] = "HIBA! Csak 'előkészített' státuszú tétel tölthető tartályba!"
      redirect_to foamrequests_path
    end  
  end


  private

  def set_request
    @request = KOM_HABIGENYLES.find(params[:id])
  end


end