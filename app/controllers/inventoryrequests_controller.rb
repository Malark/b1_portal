class InventoryrequestsController < ApplicationController

  Label = Struct.new(:itemcode, :quantity, :prod_date, :prod_time, :package_unit, :package_type, :packager_id, :qainspector_id, :charge_nr)

  def inventory_request_index
    @actu_step = 1
  end

  def check_internal_label_ir
    if params[:internal_label].blank?
      @actu_step = 1
      flash.now[:danger] = "A belső címke QR kódja nem lehet üres!"
    else
      #With String manipulation get the data form the barcode
      # Test QR code: 14032V2;125;M;200422143021;053;Standard;2020.04.22;14:30:21;csomagolt
      # positions:        0  ; 1 ;2;      3     ; 4 ;    5   ;     6    ;    7   ;    8
      internal_label = params[:internal_label]
      values = internal_label.split(";")
      if values.count < 9
        puts "bell\a"
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
          flash.now[:danger] = "Doboz címke szkennelése történt! Doboz címke nem könyvelhető át!"
        else
          #date formatting
          production_date = values[6].tr(".", "-")
          #Date Validation check: eg: '17908;13;M;200100000000;00;Standard;2020.01.00;00:00:00;csomagolt'
          if production_date[8..9] == '00'
            @actu_step = 1
            flash.now[:danger] = "Érvénytelen dátum a belső címkén: #{production_date}! Készletáttárolás nem folytatható!"
          else  
            $label = Label.new(  values[0].upcase, values[1], production_date, values[7],  label_type, values[5],  values[4], '', values[3])
            #$label = @label
            #@label = Label.new('14032V2',  125,       '2020-04-22',    '14:30:21', 'Raklap',   'Standard', '030',         '200422143021')

            #Check the charge_id is it alerady exists in the system
            internal_label_record = KOM_GYARTBEERK.search_internal_label($label.charge_nr, $label.itemcode)
            
            if internal_label_record = nil
              puts "bell\a"
              @actu_step = 1
              flash.now[:danger] = "A #{$label.charge_nr} sarzsszámú raklap nem található!"
            else
              #session[:label] = @label
              itemname = OITM.search_itemname($label.itemcode)
              if itemname != nil
                itemname.each do |row|
                  @itemname = row["ItemName"]
                end
              end
              session[:itemname] = @itemname

              #Step 1. Meg kell keresni, hogy éppen melyik tárhelyen van a raklap
              @tarolohely = ''
              $source_whscode = ''
              $source_sl1code = ''
              @unit = KOM_ATTAROLAS.search_batch_location($label.charge_nr, $label.itemcode)
              if @unit == nil
                @tarolohely = "Nem található készleten ez a sarzs: #{$label.charge_nr}! Készletáttárolás nem folytatható!"
              else
                # Modify MarkedQty to 0 if not exists
                # 16680;125;M;210503030632;053;Standard;2021.05.03;03:06:32;csomagolt
                @unit.each do |item|
                  @tarolohely = "#{item['Sl1Code']} (#{item['WhsCode']})" 
                  $source_whscode = item['WhsCode']
                  $source_sl1code = item['Sl1Code']
                end
              end  
              @actu_step = 2
            end
          end  
        end  
      end
    end  
    respond_to do |format|
      format.js { render partial: 'inventory_requests' }
    end      
  end    


  def get_storage_id_ir
    @actu_step = 3
    respond_to do |format|
      format.js { render partial: 'inventory_requests' }
    end    
  end


  def check_storage_id_ir
    if params[:storage_id].blank?
      flash.now[:danger] = "A tárolóhely azonosító nem lehet üres!"
      @actu_step = 3
    else
      storage = OBIN.search_storage(params[:storage_id])
      if storage == nil
        flash.now[:danger] = "#{params[:storage_id]} tárolóhely nem létezik! Kérem adjon meg létező tárhely kódot!"
        @actu_step = 3        
      else  
        @tarolohely   = storage['SL1Code']
        $dest_whscode = storage['WhsCode']
        $dest_sl1code = @tarolohely      
        #puts @tarolohely
        #puts $dest_whscode
        #puts $dest_sl1code
        @actu_step = 4
      end
    end  
    respond_to do |format|
      format.js { render partial: 'inventory_requests' }
    end        
  end  


  def set_storage_id_ir
    #if params[:storage_id].blank?
    #  flash.now[:danger] = "A tárolóhely azonosító nem lehet üres!"
    #  @actu_step = 3
    #else
    #  storage = OBIN.search_storage(params[:storage_id])
    #  if storage == nil
    #    flash.now[:danger] = "#{params[:storage_id]} tárolóhely nem létezik! Kérem adjon meg létező tárhely kódot!"
    #    @actu_step = 3        
    #  else  
        #puts $label.charge_nr
        #puts $source_whscode
        #puts $source_sl1code
        #puts $dest_whscode
        #puts $dest_sl1code
        d = DateTime.now
        attarolas = KOM_ATTAROLAS.new
        attarolas.U_ITEMCODE = $label.itemcode
        attarolas.U_QUANTITY = $label.quantity
        attarolas.U_SARZSSZAM = $label.charge_nr
        attarolas.U_KIAD_RAKTAR = $source_whscode
        attarolas.U_KIAD_TARHELY = $source_sl1code
        attarolas.U_FOGAD_RAKTAR = $dest_whscode
        attarolas.U_FOGAD_TARHELY = $dest_sl1code
        attarolas.U_RAKTAROS = current_user.username  
        attarolas.U_CREATEDATE = d.strftime "%Y-%m-%d  %H:%M:%S"
        if attarolas.save
          @actu_step = 5
        else
          @actu_step = 1
          flash[:danger] = "Sikertelen áttárolási kísérlet! Ismételje meg a folyamatot!"
        end
    #  end  
    #end

    respond_to do |format|
      format.js { render partial: 'inventory_requests' }
    end    
  end

end