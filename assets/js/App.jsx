import React, { Component } from "react";
import Card from "./Card.jsx";

class App extends Component {
  constructor() {
    super();
    this.state = {
      searchText: "",
      isLoading: false,
      isValid: false,
      items: []
    }

    this.handleSearchClick = this.handleSearchClick.bind(this);
    this.handleEnterClick = this.handleEnterClick.bind(this);
    this.handleInput = this.handleInput.bind(this);
  }

  handleInput(event) {
    this.setState({
      searchText: event.target.value
    });
  }

  handleEnterClick(event) {
    event.preventDefault();

    if (event.keyCode === 13) {
      this.handleSearchClick()
    }
  }

  handleSearchClick() {
    const { searchText, isValid, isLoading } = this.state;

    if (!isLoading && searchText) {
      this.setState({
        isLoading: true,
        isValid: false
      })

      this.search(searchText)
        .then(response => response.json())
        .then(json => this.setState({
          items: json.data,
          isValid: true,
          isLoading: false
        }));
    }
  }

  search(query) {
    return fetch("/api/search", {
      "method": "POST",
      "headers": new Headers({
        "Accept": "application/json",
        "Content-Type": "application/json"
      }),
      "body": JSON.stringify({ query: query })
    })
  }


  render() {
    const { searchText, items, isValid, isLoading } = this.state;

    return (
      <div className="section container main">
        <div className="content has-text-centered">
        <h1 className="title is-size-1">Beats</h1> 
          <div className="search section field has-addons ">
            <div className="control">
              <input onChange={this.handleInput} onKeyUp={this.handleEnterClick} value={searchText} className="input is-medium" type="text" placeholder="Title, artist, album..." />
            </div>
            <div className="control">
              <a onClick={this.handleSearchClick} type="submit" className={`button is-primary is-medium ${isLoading && "is-loading"}`} tabIndex="0">Search</a>
            </div>
          </div>

          {!isLoading && isValid && items.map((item) =>
            <Card key={item.id} {...item} />
          )}
        </div>
      </div>
    )
  }
}

export default App;