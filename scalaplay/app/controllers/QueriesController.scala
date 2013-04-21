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
import views.html._
import play.api.templates.Html

object QueriesController extends Controller {

  def index = Action { implicit request =>
    Ok(views.html.index("DB Project - TODO"))
  }

  def query(id: Int) = Action { implicit request =>
    Queries.select(id).map {
      case (q, dicts) => Ok(views.html.query(q, dicts))
    }.getOrElse( Redirect(routes.QueriesController.index).flashing( "error" -> "This query doesn't exist." ) )
  }

  def todo = TODO

}