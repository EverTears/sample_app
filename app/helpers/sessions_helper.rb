module SessionsHelper

	#登录指定的用户
	def log_in(user)
		session[:user_id] = user.id
	end

	# 在持久会话中记住用户
	def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
	end

	# 如果指定用户是当前用户，返回true
	def current_user?(user)
		user == current_user 
	end

	# # 返回当前登录的用户（如果有的话）
	# def current_user
	# 	@current_user ||= User.find_by(id: session[:user_id])
	# end

	# 如果用户已登录，返回true，否则返回false
	def logged_in?
		!current_user.nil?
	end

	# 返回cookie中记忆令牌队友的用户
	def current_user
		if (user_id = session[:user_id]) 
			@current_user ||= User.find_by(id: user_id)
		elsif (user_id = cookies.signed[:user_id])
			# raise # 测试仍能通过，所以没有覆盖这个分支
			user = User.find_by(id: user_id)
			if user && user.authenticated?(cookies[:remember_token])
				log_in user
				@current_user = user 
			end
		end
	end

	# 忘记持久会话
	def forget(user)
		user.forget
		cookies.delete(:user_id)
		cookies.delete(:remember_token)
	end

	#退出当前用户
	def log_out
		forget(current_user)
		session.delete(:user_id)
		@current_user = nil
	end

	# 重定向到存储的地址，或者默认地址
	def redirect_back_or(default)
        redirect_to(session[:forwarding_url] || default)
		session.delete(:forwarding_url) 
	end

	# 存储以后需要获取的地址
	def store_location
		session[:forwarding_url] = request.url if request.get? 
	end
	
end
