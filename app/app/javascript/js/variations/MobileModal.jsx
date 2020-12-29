import React from 'react';
import ReactDOM from 'react-dom';

export default class MobileModal extends React.Component {

    constructor(props) {
        super(props)
        console.log(this.props)
    }

    render() {
        const isOpen = this.props.isOpen ? 'is-active' : '';

        return(
            <div className={`modal is-hidden-desktop ${isOpen}`}>
                <div className="modal-background"></div>
                <div className="modal-card">
                    <header className="modal-card-head">
                        <p className="modal-card-title">Modal title</p>
                        <button onClick={() => this.props.mobileModalCloseHandler()}
                                className="delete" aria-label="close"></button>
                    </header>
                    <section className="modal-card-body">
                        {/* Diff partial use here */}
                        {this.props.content}
                    </section>
                    <footer className="modal-card-foot">
                        <button className="button is-success">Save changes</button>
                        <button className="button">Cancel</button>
                    </footer>
                </div>
            </div>
        )
    }

}
