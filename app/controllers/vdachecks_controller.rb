class VdachecksController < ApplicationController

  def check_vda_index
    @actu_step = 1
  end

  
  def check_internal_label
    #teszt kód: 14032V2;125;M;200422143021;053;Standard;2020.04.22;14:30:21;csomagolt
    if params[:internal_label].blank?
      @actu_step = 1
      flash.now[:danger] = "A belső címke QR kódja nem lehet üres!"
    else
      puts params[:internal_label]
      # Split this string on a space.
      input = params[:internal_label]
      values = input.split(";")
      # Display each value to the console.
      #values.each do |value|
      #  puts value
      #end
      @actu_step = 2
      session[:internal_itemcode] = values[0]
      session[:internal_charge_nr] = values[3]
    end

    respond_to do |format|
      format.js { render partial: 'check_vda_labels' }
    end
  end  


  def check_vda_label
    if params[:vda_label].blank?
      @actu_step = 2
      flash.now[:danger] = "Olvasson be érvényes belső címke QR kódot!"
    else
      @actu_step = 3

      # 1. get VDA label ID
      label = params[:vda_label]
      if label.length == 22   #In case of AUDI (label example: 6JUN364740217000070179)
        label = (label[13,label.length-1]).to_i.to_s
      else  #Volvo, Daimler, BMW  (label example: M77079)
        if label.length > 1 
          label = label[1,label.length-1]
        end
      end

      # 2. check the two scanned itemcode
      @checked = false
      owsd_itemcode = ""
      owsd_label_record = MOS_OWSD.search_master_label_by_label_id(label)
      if owsd_label_record == nil
        @checked = false
        @result_text = "Hiba! Nem létező raklap címke sorszám a címkekiosztás táblában! (#{label})"
      else #if owsd_record was found
        if owsd_label_record.length >= 1
          owsd_label_record.each do |row| 
            owsd_itemcode = row["U_ItemCode"]
          end
        end
        if session[:internal_itemcode] == owsd_itemcode
          @checked = true
        else
          @checked = false
          @result_text = "Az ellenőrzött cikkszámok eltérnek! Belső címke cikkszám: #{session[:internal_itemcode]} <=> VDA cikkszám: #{owsd_itemcode}"
        end
      end

      # 3. check the VDA label: was it used earlier anywhere or not?
      if @checked
        internal_label_record_with_master = KOM_GYARTBEERK.search_master_label(label)
        if internal_label_record_with_master != nil
          @checked = false
          @result_text = "A beolvasott VDA címke sorszám (#{label}) már használatban van!"
        end
      end

      # 4. update the internal label record in KOM_GYARTBEERK table
      if @checked
        internal_label_record = KOM_GYARTBEERK.search_internal_label(session[:internal_charge_nr], session[:internal_itemcode])
        if internal_label_record == nil
          @checked = false
          @result_text = "A két cikkszám megegyezik, viszont nem található gyártási beérkezés ezen a sarzsszámon: #{session[:internal_charge_nr]} és cikkszámon: #{session[:internal_itemcode]}"
        else
          # 5. check the internal record: U_VDASORSZAM field needs to be empty
          internal_master_label = ""
          internal_label_record.each do |row| 
            internal_master_label = row["U_VDASORSZAM"]
          end
          if internal_master_label.present?
            @checked = false
            @result_text = "A #{session[:internal_charge_nr]} sarzsszámú raklaphoz már történt VDA címke hozzárendelés! (VDA címke: #{internal_master_label})"
          else
            KOM_GYARTBEERK.update_internal_label(session[:internal_charge_nr], session[:internal_itemcode], label, current_user.username)
            @result_text = "Az ellenőrzött cikkszámok megegyeznek! Sikeres rögzítés! Cikkszám: #{owsd_itemcode}, Raklap címke: #{label}"
          end
        end
      end
    end

    #show results
    respond_to do |format|
      format.js { render partial: 'check_vda_labels' }
    end    

  end

end