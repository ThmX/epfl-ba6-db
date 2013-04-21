package models

import play.api._
import play.api.data._
import play.api.data.Forms._
import play.api.db._
import play.api.mvc._
import play.api.Play.current
import anorm._
import anorm.SqlParser._
import views.html.helper.options

case class Query(val name: String, val desc: String, val query: String, val keys: List[String])

object Queries {

  val queries = List(
    new Query(
      "Query F",
      "List names of all athletes who competed for more than one country.",
      """SELECT A.name as name
	FROM Athletes A
	WHERE (
		SELECT COUNT(AC.country_id)
		FROM Athletes_represent_Countries AC
		WHERE A.id = AC.athlete_id
	) > 1""",
      List("name")
    )
  )

  def select(id: Int) = DB.withConnection { implicit connection =>
    try {
      val qry = queries(id)
      Some((qry,
        SQL(qry.query.toString)().map { row =>
          qry.keys.map(k => k -> row[String](k)).toMap
        }.toList))
    } catch {
      case t: IndexOutOfBoundsException => None
    }

  }

}