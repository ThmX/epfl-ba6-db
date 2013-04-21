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

object EventDGController extends Controller {

  def entity = EventDG

  def template(list: List[((Discipline, Sport), (Game, Country))])(implicit flash: Flash): Html = views.html.events.apply(list)(flash)

  def routeList = routes.EventDGController.list
  def routeSave = routes.EventDGController.save

  def list = Action { implicit request =>
    Ok(template(entity.list))
  }

  def addForm(form: Form[_])(implicit flash: Flash) = html.insertForm(
    "Relations",
    "Add " + entity.table.toLowerCase,
    routeSave,
    routeList,
    form,
    entity.fields
  )

  def add = Action { implicit request =>
    Ok(addForm(entity.form))
  }

  def save = Action { implicit request =>
    entity.form.bindFromRequest.fold(
      formWithErrors => BadRequest(addForm(formWithErrors)),
      value => {
        entity.insert(value) match {
          case 0 => Redirect(routeList).flashing("error" -> "Unable to insert the relation into %s".format(entity.table))
          case n => Redirect(routeList).flashing("success" -> "The relation has been inserted into %s".format(entity.table))
        }
      }
    )
  }

  def delete(did: Long, gid: Long) = Action {
    entity.delete(did, gid) match {
      case 0 => Redirect(routeList).flashing("error" -> "Unable to delete the relation from %s".format(entity.table))
      case n => Redirect(routeList).flashing("success" -> "The relation has been deleted from %s".format(entity.table))
    }
  }

}
