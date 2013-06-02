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

case class Participant(athlete_id: Long, country_id: Long, discipline_id: Long, games_id: Long, ranking: Int)

object Participant {
  
  val table = "Representant_participates_Event"

  lazy val simple = {
    Athlete.simple ~ Country.simple ~ Discipline.simple ~ Game.simple ~ get[Int](table + ".ranking") map {
      case athlete ~ country ~ discipline ~ game ~ ranking => (athlete, country, discipline, game, ranking)
    }
  }

  lazy val form = Form(
    mapping(
      "athlete_id" -> longNumber,
      "country_id" -> longNumber,
      "discipline_id" -> longNumber,
      "games_id" -> longNumber,
      "ranking" -> number(0, 2)
    )(Participant.apply)(Participant.unapply)
  )

  lazy val fields = List(
    ('select, "athlete_id", "Athlete", Some(Athlete.options)),
    ('select, "country_id", "Country", Some(Country.options)),
    ('select, "discipline_id", "Discipline", Some(Discipline.options)),
    ('select, "games_id", "Game", Some(Game.options)),
    ('input, "year", "Year", None)
  )

  def list = DB.withConnection { implicit connection =>
    SQL("""SELECT *
    		FROM %s RE, %s A, %s C, %s D, %s S, %s G
    		WHERE RE.athlete_id = A.id AND RE.country_id = C.id AND RE.discipline_id = D.id AND S.id = D.sport_id AND
    			RE.games_id = G.id
    		LIMIT 20
        """.format(table, Athlete.table, Country.table, Discipline.table, Sport.table, Game.table)
    ).as(simple *)
  }

  def insert(that: Participant) = DB.withConnection { implicit connection =>
    SQL("insert into " + table + " (athlete_id, country_id) values ( {aid}, {cid} )").on(
      'aid -> that.athlete_id,
      'cid -> that.country_id
    ).executeUpdate()
  }

  def delete(aid: Long, cid: Long) = DB.withConnection { implicit connection =>
    SQL("delete from " + table + " where athlete_id = {aid} and country_id = {cid}").on(
      'aid -> aid,
      'cid -> cid
    ).executeUpdate()
  }

}