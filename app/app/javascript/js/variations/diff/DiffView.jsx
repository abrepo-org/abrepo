import React from 'react';
import ReactDOM from 'react-dom';
import DiffSummary from './DiffSummary.jsx';
import ButtonLaunchModalDetail from './ButtonLaunchModalDetail.jsx';

export default class DiffView extends React.Component  {

    constructor(props) {
        super(props);
    }

    render() {

        if (!this.props.diff) return null;

        return(
            <>

            { this.props.diff.summary_delta &&
              <div class="is-flex is-justify-content-space-between is-align-items-center">

                  <div className="diff-summary-delta is-size-5">
                  {this.props.diff.summary_delta}
                </div>

                {this.props.detail &&
                 <ButtonLaunchModalDetail {...this.props}/>
                }
              </div>
            }

            {  !this.props.diff.newDim.isVisible &&
               !this.props.diff.origDim.isVisible &&
               <div className="has-text-grey is-size-7">
                   Not Visible
               </div>
            }

            <div className="diff-summary-wrap">

                <DiffSummary summary={this.props.diff.summary_removed}
                             icon="&#65293;"
                             colorClass='icon-remove'
                />

                <DiffSummary summary={this.props.diff.summary_added}
                             icon="&#65291;"
                             colorClass='icon-add'
                />

            </div>
            </>
        )
    }
}
