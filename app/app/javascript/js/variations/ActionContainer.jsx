import React from 'react';
import ReactDOM from 'react-dom';

export default class ActionContainer extends React.Component {

    constructor(props) {
        super(props);
        console.log("ActionContainer");
    }

    render() {
        if (!this.props.action) return null;

        return(

            <div className="columns">
              <div className="column is-full">

                <h3> Actions </h3>

                <p> id: { this.props.action.id }</p>
                <p> Action Type: { this.props.action.type } </p>
                <p> Selector Type: { this.props.action.selector } </p>
                <p> URL: { this.props.action.url } </p>

              </div>
            </div>

        );

    }
}
