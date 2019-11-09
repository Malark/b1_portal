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