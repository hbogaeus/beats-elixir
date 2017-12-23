import React, { Component } from "react";
import Card from "./Card.jsx";

class App extends Component {

  render() {
    const test = {
      artist: "Christian Löffler",
      title: "Beirut",
      image_url: "https://i.scdn.co/image/ae8c03fb66b878b9e7f9d39aa2ca8a4907b1cfec",
      bpm: "123"
    }

    return (
      <div className="container">
        <div className="field has-addons">
          <div className="control">
            <input className="input" type="text" placeholder="Search" />
          </div>
          <div className="control">
            <a className="button is-primary">Search</a>
          </div>
        </div>

          <Card {...test} />
          <Card {...test} />
          <Card {...test} />
          <Card {...test} />
      </div>
    )
  }
}

export default App;