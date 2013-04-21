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

abstract class EntityController[T, L](val entity: Entity[T, L]) extends Controller {

  def template(list: List[L])(implicit flash: Flash): Html
  def routeList: Call
  def routeSave: Call
  def routeUpdate: Long => Call

  def list = Action { implicit request =>
    Ok(template(entity.list))
  }

  def addForm(form: Form[_])(implicit flash: Flash) = html.insertForm(
    "Entities",
    "Add " + entity.table,
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
          case 0 => Redirect(routeList).flashing("error" -> "Unable to insert %s into %s".format(value, entity.table))
          case n => Redirect(routeList).flashing("success" -> "%s has been inserted into %s".format(value, entity.table))
        }
      }
    )
  }

  def editForm(id: Long, form: Form[_])(implicit flash: Flash) = html.editForm(
    "Entities",
    "Edit " + entity.table,
    routeUpdate(id),
    routeList,
    form,
    entity.fields
  )

  def edit(id: Long) = Action { implicit request =>
    entity.findById(id).map {
      value => Ok(editForm(id, entity.form.fill(value)))
    }.getOrElse(
      Redirect(routeList).flashing("error" -> "Unable to find element with if %d in %s".format(id, entity.table))
    )
  }

  def update(id: Long) = Action { implicit request =>
    entity.form.bindFromRequest.fold(
      formWithErrors => BadRequest(editForm(id, formWithErrors)),
      value => entity.update(id, value) match {
        case 0 => Redirect(routeList).flashing("error" -> "Unable to update %s in %s".format(value, entity.table))
        case n => Redirect(routeList).flashing("success" -> "%s has been updated in %s".format(value, entity.table))
      }
    )
  }

  def delete(id: Long) = Action {
    entity.findById(id).map {
      value =>
        entity.delete(id) match {
          case 0 => Redirect(routeList).flashing("error" -> "Unable to delete %s from %s".format(value, entity.table))
          case n => Redirect(routeList).flashing("success" -> "%s has been deleted from %s".format(value, entity.table))
        }
    }.getOrElse(NotFound)
  }

}

object AthleteController extends EntityController[Athlete, Athlete](Athlete) {
  
  override def template(list: List[Athlete])(implicit flash: Flash): Html = views.html.athletes.apply(list)(flash)
  
  override def routeList = routes.AthleteController.list
  override def routeSave = routes.AthleteController.save
  override def routeUpdate = routes.AthleteController.update
}

object CountryController extends EntityController[Country, Country](Country) {

  override def template(list: List[Country])(implicit flash: Flash): Html = views.html.countries.apply(list)(flash)

  override def routeList = routes.CountryController.list
  override def routeSave = routes.CountryController.save
  override def routeUpdate = routes.CountryController.update

}

object SportController extends EntityController[Sport, Sport](Sport) {

  override def template(list: List[Sport])(implicit flash: Flash): Html = views.html.sports.apply(list)(flash)

  override def routeList = routes.SportController.list
  override def routeSave = routes.SportController.save
  override def routeUpdate = routes.SportController.update

}

object DisciplineController extends EntityController[Discipline, (Discipline, Sport)](Discipline) {

  override def template(list: List[(Discipline, Sport)])(implicit flash: Flash): Html = views.html.disciplines.apply(list)(flash)

  override def routeList = routes.DisciplineController.list
  override def routeSave = routes.DisciplineController.save
  override def routeUpdate = routes.DisciplineController.update

}

object GameController extends EntityController[Game, (Game, Country)](Game) {

  override def template(list: List[(Game, Country)])(implicit flash: Flash): Html = views.html.games.apply(list)(flash)

  override def routeList = routes.GameController.list
  override def routeSave = routes.GameController.save
  override def routeUpdate = routes.GameController.update

}





