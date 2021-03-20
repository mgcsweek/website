import Model from require 'lapis.db.model'
class Applications extends Model
    @relations: {
        { "chosen_tasks", has_many: "ChosenTasks", order: "task" }
        { "uploads", has_many: "Uploads" }
    }

class ChosenTasks extends Model
    @relations: {
        { "application", belongs_to: "Application" }
    }

class Uploads extends Model
    @relations: {
        { "application", belongs_to: "Application" }
    }

class NewsletterApplications extends Model
    @primary_key: "email"

class SecurityCredentials extends Model
    @primary_key: "application_id"
    @relations: {
        { "application", belongs_to: "Application" }
    }

{ :Applications, :ChosenTasks, :Uploads, :NewsletterApplications, :SecurityCredentials }

