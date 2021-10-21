import React from 'react';
import ReactDOM from 'react-dom';
import SelectDropDown from './SelectDropDown.jsx';
import UserSaveButton from './diff/UserSaveButton.jsx';

export default class ControlsContainer extends React.Component {

    constructor(props) {
        super(props);
        console.log('controlsContainer');
    }

    render() {
        return(
            <div className="controls">
                <div className="columns">
                    <div className="column is-3 is-hidden-touch">

                        <div className="columns">
                            <div className="column is-full">

                                {/* diff control placeholders */}

                                <p className="buttons">

                                    <button className="button"
                                            title="Hide"
                                            onClick={() => this.props.toggleDiffVisibleHandler()}>

                                        <span className="icon-text">
                                            <span className="icon is-small">
                                                {this.props.diffVisible ?
                                                 <i className="far fa-eye-slash"></i> :
                                                 <i className="far fa-eye"></i>
                                                }
                                            </span>
                                        </span>
                                    </button>

                                    <UserSaveButton
                                        id={this.props.data.variant_id}
                                        saved={this.props.data.saved}
                                        user_signed_in={this.props.data.user_signed_in}
                                    />
                                </p>

                            </div>
                        </div>

                    </div>

                    <div className="column is-full renderableControls">

                        {/* renderable control placeholders */}

                        <div className="buttons">

                            <SelectDropDown {...this.props} />

                            <button className="button"
                                    onClick={() => this.props.togglebboxClickHandler()}>
                                <span className="icon is-small" title="toggle bounding boxes">
                                    {this.props.bboxVisible ?
                                     <i className="fas fa-toggle-on"></i> :
                                     <i className="fas fa-toggle-off"></i>
                                    }
                                </span>
                            </button>

                            <button className="button is-hidden-touch"
                                    onClick={() => this.props.toggleScrollBoxHandler()}>
                                <span className="icon is-small" title="toggle scroll adjust">
                                    {this.props.scrollBoxEnabled ?
                                     <i className="fas fa-lock-open"></i> :
                                     <i className="fas fa-lock"></i>
                                    }
                                </span>
                            </button>

                            {/* reset */}
                            {this.props.scrollBoxEnabled &&
                            <button className="button is-hidden-touch"
                                    onClick={() => this.props.resetScrollBoxHandler()}>
                                <span className="icon is-small" title="toggle scroll adjust">
                                    <i className="fas fa-level-up-alt"></i>
                                </span>
                            </button>
                            }
                        </div>

                    </div>
                </div>
            </div>
        );
    }

}
