/*******************************************************************************
 * Copyright (c) 2012-2017 Red Hat, Inc.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   Red Hat, Inc. - initial API and implementation
 *******************************************************************************/
package com.redhat.bayesian.lsp.inject;

import com.redhat.bayesian.lsp.server.BayesianServerLauncher;
import org.eclipse.che.api.languageserver.launcher.LanguageServerLauncher;
import org.eclipse.che.inject.DynaModule;

import com.google.inject.AbstractModule;
import com.google.inject.multibindings.Multibinder;



/**
 * 'Test' Language Server Module
 */
@DynaModule
public class BayesianLspModule extends AbstractModule {
	@Override
	protected void configure() {
		Multibinder.newSetBinder(binder(), LanguageServerLauncher.class).addBinding()
				.to(BayesianServerLauncher.class);
	}
}
