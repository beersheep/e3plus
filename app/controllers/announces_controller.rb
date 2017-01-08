class AnnouncesController < ApplicationController
    before_action :set_announce, only: [ :show, :edit, :update, :destroy ]
    before_action :set_courses, only: [ :new, :create, :show, :edit, :update ]
    
    layout :determine

    def index
    end

    def show
        @user = User.find(session[:user_id])
        @cards = Announce.where(course_id: @courses, tag_id: [2,3]).order("deadline")
        @message = Message.new
    end

    def new
        @announce = Announce.new
    end

    def edit_msg
        @message = Message.find(params[:id])
    end

    def create
        @announce = Announce.new(announce_params)
        if @announce.save
            #new hw
            if @announce.tag_id == 3#it is an hw announce
                add_new_hw(@announce)
            end

            redirect_to controller: 'ta', action: 'index'
        else
            flash[:notice] = '所有欄位皆為必填！'
            redirect_to :new_announce
        end
    end

    def edit
    end

    def update
        if @announce.update(announce_params)
            redirect_to controller: 'ta', action: 'index'
        else
            flash[:notice] = '所有欄位皆為必填！'
            redirect_to action: 'edit'
        end
    end

    def destroy
        @announce.destroy
        redirect_to controller: 'ta', action: 'index'
    end

    private

    def set_announce
        @announce = Announce.find(params[:id])
    end

    def set_courses
        @courses = User.find(session[:user_id]).courses.all
    end

    def add_new_hw(announce)
        announce.course.users.each do |user|
            if user.identity == "student"
                hw = Homework.new(announce_id: announce.id, user: user)
                hw.status = 1
                hw.save
            end
        end
    end

    #data validation
    def announce_params
      params.require(:announce).permit(:course_id, :tag_id, :topic, :content, :deadline)
    end

    def determine
        (User.find(session[:user_id]).identity == "student") ? 'student' : 'ta'
    end

end
