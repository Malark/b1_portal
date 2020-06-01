class FoamrequestsController < ApplicationController
  before_action :set_request, only: [:edit, :update, :delete_request, :prepare_request, :use_prepared_request]
  

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
      flash[:danger] = "Sikerltelen törlési kísérlet! Csak új igényt lehet törölni, előkészített vagy lezárt tétel nem törölhető!"
    end  
    redirect_to foamrequests_path
  end


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
            session[:product_itemcode] = itemcode
            session[:foam_system] = @item["U_HABRENDSZER"]

            #Foam system analysis
            @iso_component = ITT1.search_iso_component(@item["U_HABRENDSZER"])
            if @iso_component == nil
              error = true
              @error_message += "A #{session[:foam_system]} habrendszerben nincs ISO komponens definiálva! *** "
            end
            @poliol_component = ITT1.search_poliol_component(@item["U_HABRENDSZER"])
            if @poliol_component == nil
              error = true
              @error_message += "A #{session[:foam_system]} habrendszerben nincs POLIOL komponens definiálva! *** "
            end
            @additives = ITT1.search_additives(@item["U_HABRENDSZER"])

            #Are there opened production orders?
            @prod_orders = OWOR.search_opened_production_orders(s_itemcode)
            if @prod_orders == nil
              error = true
              @error_message += "A #{s_itemcode} cikknek nincsenek nyitott gyártási rendelései! "
            end
      
            #Are the two foam systems equivalent?
            if @item["U_HABRENDSZER"] != @foam_machine["U_AKTUHABRENDSZER"]
              error = true
              @error_message += "A #{s_itemcode} termék habrendszere (#{@item["U_HABRENDSZER"]}) nem egyezik meg a gépben tárolt habrendszerrel (#{@foam_machine["U_AKTUHABRENDSZER"]})!  *** "
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
        d = DateTime.now
        request = KOM_HABIGENYLES.new
        request.U_STATUS = 'O'  # open status
        request.U_GEP_ID = session[:foaming_machine_id]
        request.U_FOCIKKSZAM = session[:product_itemcode]
        request.U_HABRENDSZER = session[:foam_system]
        request.U_ISO_MENNYISEG = params[:iso_qty].to_i
        request.U_POLIOL_MENNYISEG = params[:poliol_qty].to_i
        request.U_IGENYDATUM = d.strftime "%Y-%m-%d  %H:%M:%S"
        request.U_IGENYLO = current_user.username  
        request.U_CreateDate = d.strftime "%Y-%m-%d  %H:%M:%S"

        if request.save
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


  def prepare_request
    if @request.U_STATUS == 'O'
      redirect_to prepare_request_index_path      
    else
      flash[:danger] = "HIBA! Csak 'új igények' státuszú tétel készíthető össze!"
      redirect_to foamrequests_path
    end  
  end


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