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
import scala.compat.Platform

object QueriesController extends Controller {

  case class QryI(game: Long)

  lazy val form = Form(
    mapping(
      "game" -> longNumber
    )(QryI.apply)(QryI.unapply)
  )

  def query(id: Int, sel: Long = 0) = Action { implicit request =>
    val start = Platform.currentTime
    id match {
      case 8 => {
        Queries.selectParam(id, sel).map {
          case Page((q, dicts), page, offset) => {
            val stop = Platform.currentTime
            Ok(views.html.queryI(q, stop - start, form.fill(QryI(sel)), Game.options, dicts))
          }
        }.getOrElse(Redirect(routes.QueriesController.custom).flashing("error" -> "This query doesn't exist."))
      }

      case _ => {
        Queries.select(id).map {
          case Page((q, dicts), page, offset) => {
            val stop = Platform.currentTime
            Ok(views.html.query(q, stop - start, dicts))
          }
        }.getOrElse(Redirect(routes.QueriesController.custom).flashing("error" -> "This query doesn't exist."))
      }

    }
  }

  def customEmpty = Action { implicit request =>
    Ok(views.html.queryCustom("SELECT * FROM Athletes A WHERE A.id < 10", 0, 20, 0, null))
  }

  def custom = Action { implicit request =>
    try {
      val start = Platform.currentTime
      val posts = request.body.asFormUrlEncoded.getOrElse(Map()).map { a => a._1 -> a._2.head }.toMap
      val query = posts.get("query").getOrElse("SELECT * FROM Athletes A WHERE A.id < 10")
      val page = posts.get("page").getOrElse(0).toString.toInt
      val pageSize = posts.get("pageSize").getOrElse(20).toString.toInt
      Queries.custom(query, page, pageSize) match {
        case Page(dicts, page, pageSize) => {
          val stop = Platform.currentTime
          Ok(views.html.queryCustom(query, page, pageSize, stop - start, dicts))
        }
      }
    } catch {
      case t: Exception => {
        t.printStackTrace()
        Redirect(routes.QueriesController.custom).flashing("error" -> t.getMessage())
      }
    }
  }

}