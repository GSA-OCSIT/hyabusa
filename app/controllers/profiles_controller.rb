class ProfilesController < ApplicationController

  def show
    @profile = current_user.profile

    if @profile
      @profile.people.build
    else
      redirect_to new_profile_path, notice: 'You must create a profile.'
    end
  end

  def new
    if current_user.profile
      redirect_to edit_profile_path
    else
      @profile = Profile.new(permitted_params || {})
      @profile.people.build
      #@person = ProfilePerson.new
    end
  end

  def create
    @profile = Profile.new(permitted_params[:profile])
    @profile.user = current_user

    if @profile.save
      redirect_to @profile, notice: 'Profile was successfully created.'
    else
      render action: :new
    end
  end

  def edit
    @profile = current_user.profile
    @profile.people.build
  end

  def update
    @profile = current_user.profile

    if @profile.update_attributes!(permitted_params[:profile])
      flash[:notice] = 'Your profile was successfully updated.'
      redirect_to @profile, notice: 'Your profile was successfully updated.'
    else
      render action: :edit
    end
  end

  def destroy
    current_user.profile.destroy
  end

  private

  def permitted_params
    params.permit(
      :profile => [
        :profile_id,
        :contact_first_name,
        :contact_last_name,
        :contact_email,
        :entity_type_id,
        :num_employees,
        :annual_revenue,
        :annual_sales,
        :org_type,
        :company_name,
        :address1,
        :address2,
        :city,
        :state,
        :postal_code,
        :currently_exporting,
        :naics_sector,
        :naics_code,
        :duns_no,
        :people_attributes => [
          :id,
          :first_name,
          :last_name,
          :email,
          :title
        ],
      ],
    )
  end
end
