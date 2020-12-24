import React from 'react';
import ReactDOM from 'react-dom';

export default class Diff extends React.Component {

    constructor(props) {
        super(props);
        console.log("Diff", this.props.diff);
    }

    render() {
        return(
            <div
              onClick={() => this.props.diffClickHandler(this.props.diff.id)}
              onMouseEnter={ () => this.props.diffHoverHandler(this.props.diff.id)}
              onMouseLeave={ () => this.props.diffHoverHandler(0)} >

                <p> Diff: {this.props.diff.id} </p>
                <p> Selector: { this.props.diff.selector } </p>
                <p> type: { this.props.diff.diffType } </p>
                <p> summary_delta: { this.props.diff.summary_delta } </p>
                <p> summary_added: { this.props.diff.summary_added } </p>
                <p> summary_removed: { this.props.diff.summary_removed } </p>

            </div>
        );
    }
}
