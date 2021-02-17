import React from 'react';
import ReactDOM from 'react-dom';
import DiffSummary from './DiffSummary.jsx';

export default class DiffView extends React.Component  {

    constructor(props) {
        super(props);
    }

    render() {

        if (!this.props.diff) return null;

        return(
            <>

                { this.props.diff.summary_delta &&
                  <div className="diff-summary-delta is-size-5">
                      {this.props.diff.summary_delta}
                  </div>
                }


                {  !this.props.diff.newDim.isVisible &&
                   !this.props.diff.origDim.isVisible &&
                   <div className="has-text-grey is-size-7">
                       Not Visible
                   </div>
                }

                <div className="diff-summary-wrap">
                    <DiffSummary summary={this.props.diff.summary_added}
                                 icon="&#65291;"
                                 colorClass='icon-add'
                    />
                    <DiffSummary summary={this.props.diff.summary_removed}
                                 icon="&#65293;"
                                 colorClass='icon-remove'
                    />

                </div>
            </>
        )
    }
}
