class BeerkezesController < ApplicationController

  Label = Struct.new(:itemcode, :quantity, :prod_date, :prod_time, :package_unit, :package_type, :packager_id, :qainspector_id, :charge_nr)
  
  def step1
    #Scan internal label
  end


  def search_production_orders
    #Search opened production orders
    if params[:internal_label].blank?
      flash.now[:danger] = "Kérem, olvasson be egy belső címkét!"
    else
      @selected_prod_order = ''
      internal_label = params[:internal_label]
      #With String manipulation get the data form the barcode
      #....
      #@label = Label.new('01521', 50, '2019-10-10', '11:50:18', 'Raklap', 'Standard', '030', '055', '14')
      @label = Label.new('13900V2', 100, '2019-10-09', '13:52:18', 'Raklap', 'Standard', '030', '055', '13')
      #@label = Label.new('00003', 100, '2019-10-09', '13:52:18', 'Raklap', 'Standard', '030', '055', '13')
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
        flash.now[:danger] = "Azz adott cikknek nincsenek nyitott gyártási rendelései! A bevételezés nem folytatható!"
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
      beerkezes = Kom_gyartbeerk.new
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
      beerkezes.save      
    end  
  end

end
