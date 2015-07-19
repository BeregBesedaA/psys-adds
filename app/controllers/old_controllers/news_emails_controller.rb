﻿# encoding: utf-8
class NewsEmailsController < ApplicationController

  
  #before_action :set_post, only: [:show]

  
  #def index
  #  @news_emails = NewsEmail.all
  #end

  #def show
  #  I18n.locale = :ru
  #  #@news_email = NewsEmail.find(params[:id])
  #  flash[:notise] = 'Чтобы получать по почте новые и лучшие статьи, напишите'
  #end



  def create
    @news_email = NewsEmail.new(news_email_params) 
    

    flash[:name_error] = nil
  	flash[:email_error] = nil
	  flash[:word_error] = nil
 	  flash[:name] = nil
	  flash[:email] = nil
	  flash[:word] = nil
	  
 	  flash[:name] = @news_email.name
	  flash[:email] = @news_email.email
	  flash[:word] = @news_email.word	   	      
    #@news_email.type = params[:type]    
		@news_email_valid = true
		
		if @news_email.name.size < 3 or @news_email.name.size > 60 or @news_email.name == 'сюда' or @news_email.name == nil or @news_email.name == '' or @news_email == 'сюда'
		#if @news_email.name != 'TRY'
			@news_email_valid = false
			flash[:name_error] = 1 
		end
		if @news_email.email.size < 5 or @news_email.email.size > 50 or @news_email.email == nil or @news_email.email == '' or @news_email.email !~ /@/
			@news_email_valid = false
			flash[:email_error] = 2 
		end
		#@news_email.word.to_s.size > 1 or @news_email.word.to_s.size < 1 or 
		if @news_email.word !~ /[1234567890]/ or @news_email.word == nil or @news_email.word == '' or @news_email.word.to_s.size < 1 or @news_email.word.to_s.size > 1
			@news_email_valid = false
			flash[:word_error] = 3 
		end		
		
		if @news_email.use_for_news == false
			@news_email_valid = false
			flash[:use_for_news_error] = 4 
		end						

    if @news_email_valid    	
    	@news_email_valid = nil
		  flash[:name_error] = nil
			flash[:email_error] = nil
			flash[:word_error] = nil    	
      @news_email.akey = akey
      @news_email.email = @news_email.email.downcase
    
      case @news_email.typ
      
        when 'pers' then
		      @news_email.typ = nil
          if @news_email.use_for_news
		    		if NewsMailer.news_delivery_confirm(@news_email).deliver
              @news_email.use_for_news = false
              unless @news_email.save
        				unless @news_email.save
        					@news_email.save
        				end
   			      end
						else
			    		if NewsMailer.news_delivery_confirm(@news_email).deliver?
	              @news_email.use_for_news = false
	              unless @news_email.save
	        				unless @news_email.save
	        					@news_email.save
	        				end
	   			      end
							else
				  			redirect_to pers_path, notise: 'Попробуйте ещё раз'  
							end

						end
          end

          @order = Order.new		  
    	  	@order.akey = akey
          @order.new_email_id = @news_email.id 
    	  	@order.news_email_name = @news_email.name
    	  	@order.news_email_email = @news_email.email		  
          @order.type = false
          # false == pers
          @order.has_to_pay = 8
          #= Different.find(:first, conditions: { id: 1} )
        	unless @order.save
        		unless @order.save
        			unless @order.save
        			  redirect_to pers_path, notise: 'Попробуйте ещё раз'  
        			end
        		end
        	end          

          unless NewsEmail.find_by_email(@news_email.email)
            @news_email.type = nil  
            unless @news_email.save
            	unless @news_email.save
            		unless @news_email.save
              		redirect_to pers_path, notise: 'Попробуйте ещё раз'  
            		end
            	end  
            end 			
          end
		  
          if PersMailer.per_pay_email(@order).deliver
            @news_email = nil             			            
            @addresser = nil
            @order = nil
            redirect_to payments_path
		  		else
						if PersMailer.per_pay_email(@order).deliver?
            	@news_email = nil             			            
            	@addresser = nil
            	@order = nil
            	redirect_to payments_path
		  			else
							redirect_to pers_path, notise: 'Попробуйте ещё раз'
		  			 end
		  		 end

         when 'post' then
         
		       @news_email.typ = nil  
		  		 if NewsMailer.news_delivery_confirm(@news_email).deliver?
             @news_email.use_for_news = false
             unless @news_email.save  			
            	 unless @news_email.save
            		 @news_email.save
            	 end
             end
		  		 else
			  		 if NewsMailer.news_delivery_confirm(@news_email).deliver?
  	           @news_email.use_for_news = false
  	           unless @news_email.save  			
  	          	 unless @news_email.save
  	          		 @news_email.save
  	          	 end
  	           end
			  		 else
							 redirect_to post_path(params[:pp_id]), notise: 'Попробуйте ещё раз'  
		      	 end
	      	 end
           @news_email.use_for_news = false
           @news_email.typ = nil 
           unless @news_email.save  			
          	 unless @news_email.save
          		 @news_email.save
          	 end
           end
           @news_email = nil
           @addresser = nil
           redirect_to posts_path, notise: 'Чтобы получать новости сайта, проверьте свой E-mail. Спасибо' 
		  
         when 'product' then  
         
           @order = Order.new
    	  	 @order.akey = akey
           @order.new_email_id = @news_email.id 
    	  	 @order.news_email_name = @news_email.name
           @order.news_email_email = @news_email.email		  
           @order.link = params[:link]
           @order.has_to_pay = params[:has_to_pay]
           @order.product_id = params[:pp_id]
           @order.title = params[:title]
           @order.typ = @news_email.typ
           unless @order.save  			
          	 unless @order.save
          	 	@order.save
          	 end
           end           
         
		       @news_email.typ = nil
           if @news_email.use_for_news
		    		 if NewsMailer.news_delivery_confirm(@news_email).deliver
              @news_email.use_for_news = false
		           unless @news_email.save  			
		          	 unless @news_email.save
		          		 @news_email.save
		          	 end
		           end
						 else
			  			 if NewsMailer.news_delivery_confirm(@news_email).deliver
              	 @news_email.use_for_news = false
			           unless @news_email.save  			
			          	 unless @news_email.save
			           		@news_email.save
			          	 end
			           end
							 else
			  				 redirect_to product_path(params[:pp_id]), notise: 'Попробуйте ещё раз'  
							 end
						 end
           end   		  

           unless NewsEmail.find_by_email(@news_email.email)
             @news_email.typ = nil 
		         unless @news_email.save  			
		        	 unless @news_email.save
		        	 	@news_email.save
		        	 end
		         end
             @news_email = nil
           end

           if ProductEmailMailer.product_pay_email(@order).deliver
             @news_email = nil
             @addresser = nil          
             @order = nil
             redirect_to payments_path
		  		 else
  	         if ProductEmailMailer.product_pay_email(@order).deliver
  	           @news_email = nil
  	           @addresser = nil          
  	           @order = nil
  	           redirect_to payments_path
			  		 else
			    	 	redirect_to product_path(@news_email.pp_id), notise: 'Попробуйте ещё раз'  
	           end	
           end		  
        end

    else
      @news_email_valid = nil
      case(@news_email.typ)
        when 'pers' then
          @news_email.typ = nil
          redirect_to pers_path
        when 'post' then
          @news_email.typ = nil
          #redirect_to post_path(@addresser.pp_id)
          redirect_to post_path
        when 'product' then          
          @news_email.typ = nil
          redirect_to product_path(@news_email.pp_id)
          #flash[:my_product_check] = (@news_email.pp_id)          
        else
          redirect_to menus_path       
      end
    end
  end


  def confirm
    if @news_email = NewsEmail.find(:first, conditions: { id: params[:id]} ) and @news_email.akey == params[:akey] and @news_email.active == true
	
      @news_email.use_for_news = true
      @news_email.delivery_agree_date = @news_email.delivery_agree_date + Time.now.to_s + ', '
      @news_email.akey = akey
      unless @news_email.save
      	unless @news_email.save
       		@news_email.save
       	end
      end        
      @news_email = nil
      redirect_to products_path, notise: 'Вы подтвердили своё желание получать новости с сайта психолога Татьяны Вакульчик. Спасибо за доверие'

    else
      redirect_to menus_path, notise: 'Попробуйте ещё раз'
    end
  end

  def end_delivery
    if @news_email = NewsEmail.find(:first, conditions: { id: params[:id]} ) and @news_email.akey == params[:akey] and @news_email.active == true
	
        @news_email.use_for_news = false
        @news_email.delivery_off_date = @news_email.delivery_off_date + Time.now.to_s + ', '
        @news_email.akey = akey
        unless @news_email.save
        	unless @news_email.save
        		@news_email.save
        	end
        end
    		@news_email = nil   
        redirect_to mentions_path, notise: 'Вы отписались от получения новостей сайта. Очень жаль. Пожалуйста, если у Вас есть свободная минутка, оставьте свой отзыв о деятельности психолога и укажите причину отказа от рассылки'

    else
      redirect_to menus_path, notise: 'Попробуйте ещё раз'
    end
  end


  private
   
  def news_email_params
    params.require(:news_email).permit(:active, :akey, :delivery, :delivery_agree_date, :delivery_off_date, :email, :has_to_pay, :link, :number_of_success_pays, :name, :payed_sum, :pp_id, :title, :typ, :use_for_news, :word) 
  end  
  
  #def order_product_create_params  
  #  params.require(:order).permit(:account, :active, :akey, :done, :fail_datetime, :has_to_pay, :link, :new_email_id, :news_email_name, :news_email_email, :now_time, :number_of_fails, :product_id, :sum, :title, :typ, :want_datetime, :when_payed)  
  #end  
  
  
  #private

  #def set_post
  #  @news_email = NewsEmail.find(params[:id])
  #end

end