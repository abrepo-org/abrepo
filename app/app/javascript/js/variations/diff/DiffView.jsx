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

        const notVisible = !this.props.diff.newDim.isVisible &&
              !this.props.diff.origDim.isVisible;

        const DeltaFontSize = notVisible ? "is-size-6" : "is-size-5";
        const SummaryWrapFontSize = notVisible ? "is-size-7" : "is-size-6";

        return(
            <>

            { this.props.diff.summary_delta &&
              <div className="is-flex is-justify-content-space-between is-align-items-center">

                  <div className={`diff-summary-delta ${DeltaFontSize}`}>
                      {this.props.diff.summary_delta}
                  </div>

                  {this.props.detail &&
                   <ButtonLaunchModalDetail {...this.props}/>
                  }
              </div>
            }

            {  notVisible &&
               <div className="has-text-grey is-size-7">
                   Not Visible
               </div>
            }

            <div className={`diff-summary-wrap ${SummaryWrapFontSize}`}>

                <DiffSummary summary={this.props.diff.summary_added}
                             summary_format={this.props.diff.summary_added_format}
                             diff={this.props.diff}
                             detail={this.props.detail}
                             icon="&#65291;"
                             colorClass='icon-add'
                             notVisible={notVisible}
                />

                <DiffSummary summary={this.props.diff.summary_removed}
                             summary_format={this.props.diff.summary_removed_format}
                             diff={this.props.diff}
                             detail={this.props.detail}
                             icon="&#65293;"
                             colorClass='icon-remove'
                             notVisible={notVisible}
                />

            </div>
            </>
        )
    }
}
