import React from 'react';
import ReactDOM from 'react-dom';

export default class DiffView extends React.Component  {

    constructor(props) {
        super(props);
    }

    render() {

        if (!this.props.diff) return null;

        return(
            <div className="diff">

                <div className="has-text-grey">Selector</div>
                <div>{this.props.diff.selector}</div>

                <div className="has-text-grey mt-3">Summary</div>
                <div>{this.props.diff.summary_delta}</div>
                
                {/*
                <p> type: { this.props.diff.diffType } </p>
                <p> summary_delta: { this.props.diff.summary_delta } </p>
                <p> summary_added: { this.props.diff.summary_added } </p>
                <p> summary_removed: { this.props.diff.summary_removed } </p>
                */}
            </div>
        )
    }
}
