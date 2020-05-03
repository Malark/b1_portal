class BeerkezesController < ApplicationController

  Label = Struct.new(:itemcode, :quantity, :prod_date, :prod_time, :package_unit, :package_type, :packager_id, :qainspector_id, :charge_nr)
  
  def step1
    #Scan internal label
  end


  def search_production_orders
    #Search opened production orders
    if params[:internal_label].blank?
      flash.now[:danger] = "A belső címke QR kódja nem lehet üres!"
    else
      @selected_prod_order = ''
      #With String manipulation get the data form the barcode
      # Test QR code: 14032V2;125;M;200422143021;053;Standard;2020.04.22;14:30:21;csomagolt
      # positions:        0  ; 1 ;2;      3     ; 4 ;    5   ;     6    ;    7   ;    8
      internal_label = params[:internal_label]
      values = internal_label.split(";")
      #label type formatting
      label_type = ""
      if values[2] == 'M'
        label_type = 'Raklap'
      else
        label_type = 'KLT'
      end
      #date formatting
      production_date = values[6].tr(".", "-")

      @label = Label.new(values[0], values[1], production_date, values[7], label_type, values[5], values[4], '', values[3])
      #@label = Label.new('14032V2', 125, '2020-04-22', '14:30:21', 'Raklap', 'Standard', '030', '', '200422143021')

      session[:label] = @label
      itemname = OITM.search_itemname(@label.itemcode)
      if itemname != nil
        itemname.each do |row|
          @itemname = row["ItemName"]
        end
      end
      session[:itemname] = @itemname
      @prod_orders = OWOR.search_from_lookup(@label.itemcode)
      if @prod_orders == nil
        flash.now[:danger] = "A #{@label.itemcode} cikknek nincsenek nyitott gyártási rendelései! A bevételezés nem folytatható!"
      else
        if @prod_orders.length == 1
          @prod_orders.each do |row| 
            @selected_prod_order = row["DocNum"]
            puts @selected_prod_order
          end
        end
      end  
    end

    respond_to do |format|
      format.js { render partial: 'beerkezes/step1_result' }
    end
  end


  def step2
    itemcode = session[:label]["itemcode"]
    @prod_orders = OWOR.search_from_lookup(itemcode)
    if @prod_orders == nil
      flash.now[:danger] = "Az adott cikknek nincsenek nyitott gyártási rendelései! A bevételezés nem folytatható!"
    end
    @prod_orders.each do |row| 
      puts row["DocNum"]
    end
  end


  def step3
    if params[:param1].blank?
      flash[:danger] = "Kérem válassza ki a kívánt gyártási rendelést!"
      redirect_to beerkezes_gyartasbol_step2_path
    else
      @selected_prod_order = params[:param1]
    end  
  end


  def summary
    if params[:storage_id].blank?
      flash.now[:danger] = "Kérem, olvasson be egy tárolóhely azonosítót!"
    else
      @selected_storage_id = params[:storage_id]
      @selected_prod_order = params[:prod_order]
    end
    respond_to do |format|
      format.js { render partial: 'beerkezes/step3_result' }
    end
  end


  def step4
    puts params[:prod_order]
    puts params[:storage_id]
    puts session[:itemname]
    puts session[:label]["itemcode"]
    if params[:prod_order].blank?
      flash[:danger] = "Hiba a feldolgozás során! A bevételezési folyamat megszakadt!"
      redirect_to root_path
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
      beerkezes.U_RAKTAROS = "0000"  #Itt majd kell a loged User
      beerkezes.U_CreateDate = d.strftime "%Y-%m-%d  %H:%M:%S"
      #beerkezes.save      
    end  
  end

end
