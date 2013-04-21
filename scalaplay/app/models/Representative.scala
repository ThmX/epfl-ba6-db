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

case class Representative(athlete_id: Long, country_id: Long)

object Representative {
  
  val table = "Athletes_represent_Countries"

  val simple = {
    Athlete.simple ~ Country.simple map {
      case athlete ~ country => (athlete, country)
    }
  }

  val form = Form(
    mapping(
      "athlete_id" -> longNumber,
      "country_id" -> longNumber
    )(Representative.apply)(Representative.unapply)
  )

  val fields = List(
    ('select, "athlete_id", "Athlete", Some(Athlete.options)),
    ('select, "country_id", "Country", Some(Country.options))
  )

  def list = DB.withConnection { implicit connection =>
    SQL("""SELECT *
    		FROM Athletes_represent_Countries AC, Countries C, Athletes A
    		WHERE AC.athlete_id = A.id and AC.country_id = C.id"""
    ).as(simple *)
  }

  def insert(that: Representative) = DB.withConnection { implicit connection =>
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