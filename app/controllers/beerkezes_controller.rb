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
      #@label = Label.new('01521', 100, '2019-10-09', '13:52:18', 'Raklap', 'Standard', '030', '055', '13')
      @label = Label.new('13900V2', 100, '2019-10-09', '13:52:18', 'Raklap', 'Standard', '030', '055', '13')
      session[:label] = @label
      itemname = OITM.search_itemname(@label.itemcode)
      if itemname != nil
        itemname.each do |row|
          @itemname = row["ItemName"]
          puts @itemname
        end
      end
      @prod_orders = OWOR.search_from_lookup(@label.itemcode)
      if @prod_orders == nil
        flash.now[:danger] = "Az adott cikknek nincsenek nyitott gyártási rendelései! A bevételezés nem folytatható!"
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
    puts "STEP33333333333333333333333"
    puts session[:label]["itemcode"]
    @selected_prod_order = params[:param1]
    puts "VÁLTOZÓÓÓ ÉRTÉKE::::"
    puts @selected_prod_order

  end


end
