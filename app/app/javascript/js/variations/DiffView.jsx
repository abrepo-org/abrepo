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

            { (this.props.diff.summary_added || this.props.diff.summary_removed) &&
              <>
                <div className="has-text-grey mt-3">Summary</div>
                <div>{this.props.diff.summary_delta}</div>
              </>
            }

            {this.props.diff.summary_added &&
                <div>
                    <span className="icon is-small icon-add">
                        <i className="fas fa-plus"></i>
                    </span>
                    <span className="summary-added">
                        {this.props.diff.summary_added}
                    </span>
                </div>
                }

                {this.props.diff.summary_removed &&
                <div>
                    <span className="icon is-small icon-remove">
                        <i className="fas fa-minus"></i>
                    </span>
                    <span className="summary-removed">
                        {this.props.diff.summary_removed}
                    </span>
                </div>
                }

            </div>
        )
    }
}
