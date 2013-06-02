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

case class Query(val name: String, val desc: String, val query: String, val page: Int = 0, val pageSize: Int = 20)

case class Page[A](items: A, page: Int, offset: Long) {
  lazy val prev = if (page > 0) page - 1 else page
  lazy val next = page + 1
}

object Queries {

  lazy val form = Form(
    mapping(
      "name" -> ignored("Custom Query"),
      "desc" -> ignored("This is a custom Query."),
      "query" -> ignored("This is a custom Query."),
      "page" -> number,
      "pageSize" -> number
    )(Query.apply)(Query.unapply)
  )

  lazy val queries = List(
    Query(
      "Query test",
      "List names of all athletes who competed for more than one country.",
      """SELECT A.id as id, A.name as name
	FROM Athletes A
	WHERE (
		SELECT COUNT(AC.country_id)
		FROM Athletes_represent_Countries AC
		WHERE A.id = AC.athlete_id
	) > 1"""
    ),
    Query(
      "Query M",
      "List all Olympians who won medals for multiple nations.",
      """SELECT DISTINCT
    a.name,
    c1.country_id,
    c1.country_name,
    c2.country_id,
    c2.country_name
FROM
    (SELECT 
        p.athlete_id as medalist_id,
            c.id as country_id,
            c.name as country_name
    FROM
        representant_participates_event p, countries c
    WHERE
        p.ranking != 0 AND p.country_id = c.id) c1,
    (SELECT 
        p.athlete_id as medalist_id,
            c.id as country_id,
            c.name as country_name
    FROM
        representant_participates_event p, countries c
    WHERE
        p.ranking != 0 AND p.country_id = c.id) c2,
    athletes a
WHERE
    c1.medalist_id = c2.medalist_id
        AND a.id = c1.medalist_id
        AND c1.country_id < c2.country_id;"""
    ),
    Query(
      "Query I",
      "Test that shit",
      """SELECT *
	FROM Game G
	WHERE G.id = %d"""
    )
  )

  def select(id: Int, page: Int = 0, pageSize: Int = 10) = DB.withConnection { implicit connection =>
    try {
      val offest = pageSize * page
      val qry = queries(id)
      Some(Page(
        (
          qry,
          SQL(qry.query)().map { row => row.asMap.toMap }.toList
        ),
        page,
        pageSize
      ))
    } catch {
      case t: Exception => None
    }
  }

  def selectParam(id: Int, sel: Long, page: Int = 0, pageSize: Int = 10) = DB.withConnection { implicit connection =>
    try {
      val offest = pageSize * page
      val qry = queries(2) //queries(id)
      Some(Page(
        (
          qry,
          SQL(qry.query.format(sel))().map { row => row.asMap.toMap }.toList
        ),
        page,
        pageSize
      ))
    } catch {
      case t: Exception => None
    }
  }

  def custom(query: String, page: Int = 0, pageSize: Int = 20) = DB.withConnection { implicit connection =>
    val offest = pageSize * page
    Page(
      SQL(query + " limit {pageSize} offset {offset}").on(
        'pageSize -> pageSize,
        'offset -> offest
      )().map { row => row.asMap.toMap }.toList,
      page,
      pageSize
    )
  }

}