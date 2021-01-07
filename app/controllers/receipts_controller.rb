class ReceiptsController < ApplicationController

  Label = Struct.new(:itemcode, :quantity, :prod_date, :prod_time, :package_unit, :package_type, :packager_id, :qainspector_id, :charge_nr)

  def receipt_from_production_index
    @actu_step = 1
  end

  def search_production_orders
    #Search opened production orders
    if params[:internal_label].blank?
      @actu_step = 1
      flash.now[:danger] = "A belső címke QR kódja nem lehet üres!"
    else
      #@selected_prod_order = ''
      #With String manipulation get the data form the barcode
      # Test QR code: 14032V2;125;M;200422143021;053;Standard;2020.04.22;14:30:21;csomagolt
      # positions:        0  ; 1 ;2;      3     ; 4 ;    5   ;     6    ;    7   ;    8
      internal_label = params[:internal_label]
      values = internal_label.split(";")
      #puts values.count
      #values.each do |value|
      #  puts value
      #end
      if values.count < 9
        @actu_step = 1
        flash.now[:danger] = "Hibás QR kód struktúra!"
      else
        #label type formatting
        label_type = ""
        if values[2] == 'M'
          label_type = 'Raklap'
        else
          label_type = 'KLT'
        end
        if label_type == 'KLT'
          @actu_step = 1
          flash.now[:danger] = "Doboz címke szkennelése történt! Doboz címke nem vételezhető be!"
        else
          #date formatting
          production_date = values[6].tr(".", "-")
          #Date Validation check: eg: '17908;13;M;200100000000;00;Standard;2020.01.00;00:00:00;csomagolt'
          if production_date[8..9] == '00'
            @actu_step = 1
            flash.now[:danger] = "Érvénytelen dátum a belső címkén: #{production_date}! Bevételezés nem folytatható!"
          else  
            @label = Label.new(  values[0], values[1], production_date, values[7],  label_type, values[5],  values[4], '', values[3])
            #@label = Label.new('14032V2',  125,       '2020-04-22',    '14:30:21', 'Raklap',   'Standard', '030',         '200422143021')

            #Check the charge_id is it alerady used or is it a brand new palett id
            internal_label_record = KOM_GYARTBEERK.search_internal_label(@label.charge_nr, @label.itemcode)
            
            if internal_label_record != nil
              @actu_step = 1
              flash.now[:danger] = "A #{@label.charge_nr} sarzsszámú raklap már be lett vételezve korábban!"
            else
              session[:label] = @label
              itemname = OITM.search_itemname(@label.itemcode)
              if itemname != nil
                itemname.each do |row|
                  @itemname = row["ItemName"]
                end
              end
              session[:itemname] = @itemname
              @prod_orders = OWOR.search_opened_production_orders(@label.itemcode)
              if @prod_orders == nil
                @actu_step = 1
                flash.now[:danger] = "A #{@label.itemcode} cikknek nincsenek nyitott gyártási rendelései! A bevételezés nem folytatható!"
              else
                @actu_step = 2
                if @prod_orders.length == 1
                  @prod_orders.each do |row| 
                    @selected_prod_order = row["DocNum"]
                  end
                end
              end  
            end
          end  
        end  
      end
    end
    respond_to do |format|
      format.js { render partial: 'receipt_from_prod' }
    end
  end  

  def select_production_order
    itemcode = session[:label]["itemcode"]
    @itemname = session[:itemname]
    @prod_orders = OWOR.search_opened_production_orders(itemcode)
    if @prod_orders == nil
      @actu_step = 1
      flash.now[:danger] = "Hiba a #{itemcode} cikk gyártási rendeléseinek keresése közben! A bevételezés nem folytatható!"      
    else
      @actu_step = 3
    end
    respond_to do |format|
      format.js { render partial: 'receipt_from_prod' }
    end
  end


  def get_storage_id
    if params[:prod_order].blank?
      flash[:danger] = "Kérem válasszon ki egy gyártási rendelést!"
      itemcode = session[:label]["itemcode"]
      @prod_orders = OWOR.search_opened_production_orders(itemcode)
      if @prod_orders == nil
        @actu_step = 1
        flash.now[:danger] = "Hiba a #{itemcode} cikk gyártási rendeléseinek keresése közben! A bevételezés nem folytatható!"      
      else
        @actu_step = 3
      end
    else
      @selected_prod_order = params[:prod_order]
      @actu_step = 4
    end  
    respond_to do |format|
      format.js { render partial: 'receipt_from_prod' }
    end    
  end

  def set_storage_id
    @selected_prod_order = params[:prod_order]
    puts @selected_prod_order
    if params[:storage_id].blank?
      flash.now[:danger] = "A tárolóhely azonosító nem lehet üres!"
      @actu_step = 4
    else
      @actu_step = 5
      @selected_storage_id = params[:storage_id]
    end

    respond_to do |format|
      format.js { render partial: 'receipt_from_prod' }
    end    
  end

  def save_record
    if params[:prod_order].blank? || params[:storage_id].blank?
      flash[:danger] = "Hiba a feldolgozás során! A rendelésszám és a tárolóhely mező nem lehet üres! A bevételezési folyamat megszakadt!"
      @actu_step = 1
    else
      d = DateTime.now
      beerkezes = KOM_GYARTBEERK.new
      beerkezes.U_GYARTRENDSZAM = params[:prod_order]
      beerkezes.U_ItemCode = session[:label]["itemcode"]
      beerkezes.U_Quantity = session[:label]["quantity"]
      beerkezes.U_CSOMAGOLO = session[:label]["packager_id"]
      beerkezes.U_MINOSEGELLENOR = session[:label]["qainspector_id"]
      beerkezes.U_GYARTDATUM = session[:label]["prod_date"] + ' ' + session[:label]["prod_time"]
      beerkezes.U_SARZSSZAM = session[:label]["charge_nr"]
      beerkezes.U_CSOMEGYSEG = session[:label]["package_unit"]
      beerkezes.U_CSOMTIPUS = session[:label]["package_type"]
      beerkezes.U_TARHELY = params[:storage_id]
      beerkezes.U_RAKTAROS = current_user.username  
      beerkezes.U_CreateDate = d.strftime "%Y-%m-%d  %H:%M:%S"
      if beerkezes.save
        @actu_step = 6
      else
        @actu_step = 5
        @selected_storage_id = params[:storage_id]        
        flash[:danger] = "Sikertelen mentési kísérlet az adatbázisba! Ismételje meg a folyamatot!"
      end
    end

    respond_to do |format|
      format.js { render partial: 'receipt_from_prod' }
    end 
  end

end