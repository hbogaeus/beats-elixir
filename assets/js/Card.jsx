import React, { Component } from "react";

class Card extends Component {
  render() {
    const { image_url, title, artist, bpm } = this.props;
    
    return (
      <article className="media">
        <figure className="media-left">
          <p className="image is-96x96">
            <img src={image_url} />
          </p>
        </figure>
        <div className="media-content">
          <p>
            <strong>{title} - {artist}</strong>
            <br />
            {bpm} BPM
           </p>
        </div>
      </article>
    )
  }
}

export default Card;