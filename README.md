# README

Semantic UI bekapcsolása:


-> assets\javascripts\application.js

   


//= require jquery
//= require semantic-ui

    <%= @deliveries.each do |row| %>
      <strong>Delivery Note Nr: </strong><%= row["DocNum"] %>
    <% end %>

    <%= f.collection_check_boxes :delivery_docentries, @deliveries.all, :DocEntry, DocNum do |cb| %>
      <% cb.label(class: "checkbox-inline input_checkbox") {cb.check_box(class: "checkbox") + cb.text} %>
    <% end %>  

    <% @choosen_deliveries.each do |row| %>
      <ul>
        <li><%= row %></li>
      </ul>
    <% end %>  


-> assets\stylesheets\custom.css.scss

@import "semantic-ui";



ez működött, de csak az utolsó kiválaszottt elemre:

def choose
    @step2 = true

    if params[:name].blank?
      flash.now[:danger] = "Legalább 1 szállítólevél kiválasztása kötelező!"
    else
      @choosen_deliveries = params[:name]
    end
    respond_to do |format|
      format.js { render partial: 'labelchecks/deliveries' }
    end
  end


_deliveries.html.erb:

<li>
  <label class="category-select">
    <%= check_box_tag :name, row["DocNum"], false %>
    <%= row["DocNum"] %>, <%= row["DocDate"] %>
  </label>
</li>

.
.
.

<% else %>
  <% if @choosen_deliveries %>
    <strong>Master címkék ellenőrzése!</strong>
    <%= @choosen_deliveries %>
  <% end %>  
<% end %>



-----------------------------------

_check partial:

<br>
<%= render 'layouts/messages' %>

<% if !@finished %>

  <div class="well results-block">
    <strong><p>Összes raklap: <%= session[:labels].count %></p></strong>
    <strong><p>Ellenőrzött raklap: <%= session[:checked_labels].count %></p></strong>
  </div> 
 
<% else %>
  <br>
  <br>
  <%= form_tag delivery_checked_path, remote: true, method: :get, id: 'delivery-checked-form' do %>     
    <div class="form-group">
      <%= button_tag(type: :submit) do %>
        Ellenőrzés befejezése
      <% end %>
    </div>        
  <% end %>
<% end %>


--------------------------------


check_delyverr.html.erb:

<!--
<%= form_tag check_labels_path, remote: true, method: :get, id: 'check-deliveries-form' do %>     
  <div class="form-group">
    <%= text_field_tag :labelcheck2a, params[:label_id], placeholder: "Címke sorszám", autofocus: true, class: "form-control" %>
  </div>  
  <div class="form-group">
    <%= button_tag(type: :submit) do %>
      Mehet
    <% end %>
  </div>        
<% end %>
-->

---------------------------------

      <table id="prod_order_table" class="ui table">
        <thead>
          <tr>
            <th>Név</th>
            <th>Település</th>
            <th>Cím</th>
            <th>Telefon</th>
            <th>Funkciók</th>
          </tr>
        </thead>
        <tbody>
          <% @prod_orders.each do |row| %>
            <tr>
              <label class="category-select">
                <td><%= radio_button_tag :param1, row["DocNum"] , false %></td> 
                <td><%= row["DocNum"] %></td> 
                <td><%= row["DueDate"] %></td>
                <td><%= row["PlannedQty"] %></td>
                <td><%= row["CmpltQty"] %></td>
              </label>
            </tr>
          <% end %>
        </tbody>
      </table>


---------------------------------      

_deliveries.html.erb-ből az else ág, nem tudom, mire kellett:

<% else %>

  <% if @master_labels %>
    <strong>Master címkék ellenőrzése!</strong>
    <% @master_labels.each do |row| %>
      <ul>
        <li><%= row %></li>
      </ul>
    <% end %>
    <% @firstcall = false %>    
    <%= form_tag check_deliveries_path, remote: true, method: :get, id: 'check-deliveries-form' do %>     
      <div class="form-group">
        <%= text_field_tag :labelcheck2, params[:label_id], placeholder: "Scan Master Label...", class: "form-control" %>
      </div>  
      <div class="form-group">
        <%= button_tag(type: :submit) do %>
          Mehet
        <% end %>
      </div>        
    <% end %>  

    <div class="well results-block">
      <strong><p><%= @aaa %></p></strong>
    </div>
  <% end %>  

<% end %>