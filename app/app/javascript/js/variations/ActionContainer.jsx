import React from 'react';
import ReactDOM from 'react-dom';

export default class ActionContainer extends React.Component {

    constructor(props) {
        super(props);
        console.log("ActionContainer");
    }

    render() {
/*

        Behavior:

        if only default action, "null action" row is hidden - no
        discernable action.

        if only action visible change (no bbox on null action
        renderables), set the action set renderables as the default
        "start" selected view

        ----

        Layout: fixed row above controls: table view?  action [click,
        scroll]: selector: <body>, description

        on click triggers view of new diff/renderables on hover,
        highlights blue

        default action 'bbox' - 'flickering'

        on mobile, stack
*/
        return(

            <div className="columns">
              <div className="column is-full">

                <h3> Actions </h3>

                { this.props.action &&
                  <>
                  <p> id: { this.props.action.id }</p>
                  <p> Action Type: { this.props.action.type } </p>
                  <p> Selector Type: { this.props.action.selector } </p>
                  <p> URL: { this.props.action.url } </p>
                  </>
                }
                  <hr/>
              </div>
            </div>

        );

    }
}
