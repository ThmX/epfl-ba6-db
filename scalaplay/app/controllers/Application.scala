package controllers

import play.api._
import play.api.data._
import play.api.data.Forms._
import play.api.db._
import play.api.mvc._
import play.api.Play.current
import anorm._
import views._
import models._

object Application extends Controller {

  def index = Action { implicit request =>
    Ok(views.html.index("DB Project - Olympic Games"))
  }
  
  def todo = TODO

}