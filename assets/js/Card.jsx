import React, { PureComponent } from "react";

class Card extends PureComponent {
  render() {
    const { image_url, title, artist, bpm } = this.props;

    return (
      <article className="media">
        <figure className="media-left">
          <p className="image is-128x128">
            <img src={image_url} />
          </p>
        </figure>
        <div className="media-content">
          <p>
            <span><strong>{title} - {artist}</strong></span>
            <br />
            <span className="is-size-5">{Math.round(bpm)} BPM</span>
           </p>
        </div>
      </article>
    )
  }
}

export default Card;